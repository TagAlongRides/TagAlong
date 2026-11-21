const express = require("express");
const admin = require("firebase-admin");
const {stripe, stripeV2, logPlatformIdentity} = require("../lib/stripe");
const {ok, badRequest, serverError, missingBodyFields, BaseResponseModel} = require("../lib/response");
const {createDriverAccount} = require("../lib/driverAccount");
const {parseCents, chargeAmountError, applicationFeeError} = require("../lib/amount");
const {FUNDS_FLOW} = require("../lib/payouts");

const router = express.Router();




/*
 * Only the endpoints the TagAlong app actually calls are here. The previous
 * backend also exposed subscriptions, products, prices, setup intents, generic
 * transfers and a /rideboard router — none of which the client ever used, and
 * all of which were reachable unauthenticated.
 */

// ---------------------------------------------------------------- Customers

/** Creates the Stripe customer a passenger's saved cards hang off. */
router.post("/customer/", async (req, res) => {
  if (missingBodyFields(req, res, ["name", "email"])) return;
  try {
    const customer = await stripe().customers.create({
      name: req.body.name,
      email: req.body.email,
    });
    ok(res, "Account Created Successfully", customer);
  } catch (error) {
    serverError(res, error);
  }
});

router.get("/customer/:id", async (req, res) => {
  try {
    ok(res, "Account Details", await stripe().customers.retrieve(req.params.id));
  } catch (error) {
    serverError(res, error);
  }
});

/** The passenger's saved cards, shown on the payment and account screens. */
router.get("/getPaymentMethods/:customer_id", async (req, res) => {
  try {
    const paymentMethods = await stripe().paymentMethods.list({
      customer: req.params.customer_id,
      type: "card",
    });
    ok(res, "Payment method fetched Successfully", paymentMethods);
  } catch (error) {
    serverError(res, error);
  }
});


// ------------------------------------------------------------ Connect setup

/**
 * Creates the driver's connected account.
 */
router.post("/stripeConnect/account/", async (req, res) => {
  // `type` is no longer required. The v1 account type is expressed as
  // `dashboard` in v2; the client still sends `type: "express"` and it is
  // honoured, but its absence is no longer a reason to reject the request.
  if (missingBodyFields(req, res, ["email", "first_name"])) return;
  try {
    ok(res, "Account Created Successfully", await createDriverAccount(req.body));
  } catch (error) {
    // Account-creation policy is scoped to one Stripe account and one mode, so
    // a rejection here is worth pairing with which account the key is for.
    await logPlatformIdentity("v2 accounts.create");
    serverError(res, error);
  }
});

router.get("/stripeConnect/account/balance/:id", async (req, res) => {
  try {
    const balance = await stripe().balance.retrieve({stripeAccount: req.params.id});
    ok(res, "Balance Details", balance);
  } catch (error) {
    serverError(res, error);
  }
});

router.get("/stripeConnect/account/:id", async (req, res) => {
  try {
    ok(res, "Account Details", await stripe().accounts.retrieve(req.params.id));
  } catch (error) {
    serverError(res, error);
  }
});

/**
 * Hosted onboarding link the driver completes in the in-app web view.
 *
 * Accounts v2 also offers an `account_update` flow, for sending a driver back
 * to fix a requirement that has lapsed. v1 had no clean equivalent. The client
 * asks for `account_onboarding`; passing `type: "account_update"` selects the
 * other flow.
 */
router.post("/stripeConnect/", async (req, res) => {
  if (missingBodyFields(req, res, ["email", "refresh_url", "return_url"])) return;
  try {
    // The client sends the account it already created and stored against the
    // driver. An earlier implementation ignored it and created a fresh account
    // on every call, so every attempt at onboarding minted an orphan account
    // and linked the driver to that one instead of their own.
    let accountId = req.body.account_id;

    if (!accountId) {
      accountId = (await createDriverAccount(req.body)).id;
    }

    const useCase = req.body.type === "account_update" ? "account_update" : "account_onboarding";
    const accountLink = await stripeV2().v2.core.accountLinks.create({
      account: accountId,
      use_case: {
        type: useCase,
        [useCase]: {
          refresh_url: req.body.refresh_url,
          return_url: req.body.return_url,
          // Collect what Stripe needs now rather than everything that will
          // eventually be due, so onboarding asks the driver for less.
          collection_options: {fields: "currently_due"},
        },
      },
    });

    // The client reads account_id off the link to store against the driver.
    ok(res, "Stripe Connect Account link Url fetch successfully",
        {...accountLink, account_id: accountId});
  } catch (error) {
    await logPlatformIdentity("v2 accountLinks.create");
    serverError(res, error);
  }
});

// --------------------------------------------------------------- Charging

/**
 * Whether a driver's connected account can be paid.
 *
 * A destination charge used to enforce this for us: Stripe refused it unless
 * the destination could receive transfers. Charging to TagAlong's own balance
 * removes that check, so without this a passenger could pay for a ride whose
 * driver can never be paid. Same test as the app's `isStripeActive`, which
 * the Accounts v2 migration confirmed against test mode.
 */
async function driverCanBePaid(accountId) {
  let account;
  try {
    account = await stripe().accounts.retrieve(accountId);
  } catch (error) {
    // An account our key cannot see - deleted, or connected to a different
    // Stripe platform (rides posted before the 2023 account was retired still
    // name one) - can never be paid. That is the driver's setup, not an
    // outage, so it gets the same answer as an unfinished account.
    if (error && (error.code === "account_invalid" || error.code === "resource_missing")) {
      return false;
    }
    throw error;
  }
  return account.payouts_enabled === true &&
    (account.capabilities || {}).transfers === "active";
}

/**
 * The booking charge.
 *
 * The passenger pays the full fare into TagAlong's own Stripe balance. None of
 * it moves to the driver here: markRidePaid transfers the driver's share once
 * the ride is complete, in one daily payout per driver (lib/payouts.js).
 *
 * The path and request body are unchanged from when this was a destination
 * charge, so the app needs no update. `destination` and `application_fee` now
 * describe how the fare will be split later, and are stored on the payment
 * intent's metadata, which is what the payout job reads.
 */
router.post("/stripeConnect/charge/destination/paymentintent", async (req, res) => {
  if (missingBodyFields(req, res,
      ["email", "amount", "application_fee", "payment_method_id", "return_url", "destination"])) {
    return;
  }
  // Checked here, right before Stripe, so a malformed amount is a clear 400
  // rather than Stripe's "Invalid integer: NaN" surfacing as a 500.
  const amountError = chargeAmountError(req.body.amount);
  if (amountError) return badRequest(res, amountError);
  const amount = parseCents(req.body.amount);
  const feeError = applicationFeeError(req.body.application_fee, amount);
  if (feeError) return badRequest(res, feeError);
  const platformFee = parseCents(req.body.application_fee);
  const destination = String(req.body.destination);
  if (!destination.startsWith("acct_")) {
    return badRequest(res, "destination must be the driver's Stripe account id");
  }

  try {
    if (!(await driverCanBePaid(destination))) {
      return badRequest(res,
          "This driver has not finished setting up payments, so the ride cannot be booked yet.");
    }

    const paymentIntent = await stripe().paymentIntents.create({
      amount,
      currency: "usd",
      confirm: true,
      customer: req.body.customer_id,
      payment_method: req.body.payment_method_id,
      payment_method_types: ["card"],
      receipt_email: req.body.email,
      setup_future_usage: "on_session",
      return_url: req.body.return_url,
      metadata: {
        funds_flow: FUNDS_FLOW,
        driver_account: destination,
        driver_share_cents: String(amount - platformFee),
        platform_fee_cents: String(platformFee),
        ride_id: req.body.transfer_group ? String(req.body.transfer_group) : "",
      },
    });
    ok(res, "Payment Intent Created Successfully", paymentIntent);
  } catch (error) {
    serverError(res, error);
  }
});

/**
 * Cancels a booking: refunds the passenger in full.
 *
 * For a fare TagAlong is still holding this is a plain refund. Bookings made
 * while this was a destination charge also reverse the driver's transfer and
 * the application fee, as before.
 *
 * A fare that has already gone to the driver is refused rather than refunded.
 * Refunding it would leave TagAlong out the driver's share with nothing
 * recording it; that case needs someone to decide whether to recover it from
 * the driver.
 */
router.post("/stripeConnect/refundDestinationCharge", async (req, res) => {
  if (missingBodyFields(req, res, ["charge"])) return;
  try {
    const bookings = await admin.firestore().collection("rideBooking")
        .where("chargeId", "==", req.body.charge)
        .limit(1)
        .get();
    const booking = bookings.empty ? null : bookings.docs[0].data();
    if (booking && (booking.payoutBatchId || booking.status === "paid")) {
      return res.status(409).send(new BaseResponseModel(409, false,
          "This fare has already been paid out to the driver and cannot be refunded automatically. " +
          "Contact TagAlong support."));
    }

    const charge = await stripe().charges.retrieve(req.body.charge);
    const params = {charge: req.body.charge};
    if (charge.transfer || (charge.transfer_data && charge.transfer_data.destination)) {
      // A destination charge from before the switch: the driver already holds
      // their share, so take it back along with the fee.
      params.reverse_transfer = req.body.reverse_transfer !== false;
      params.refund_application_fee = req.body.refund_application_fee !== false;
    }
    const refund = await stripe().refunds.create(params);
    ok(res, "Refund processed Successfully", refund);
  } catch (error) {
    serverError(res, error);
  }
});

module.exports = router;
