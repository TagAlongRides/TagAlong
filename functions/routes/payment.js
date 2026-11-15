const express = require("express");
const {stripe, stripeV2, logPlatformIdentity} = require("../lib/stripe");
const {ok, badRequest, serverError, missingBodyFields} = require("../lib/response");
const {createDriverAccount} = require("../lib/driverAccount");

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
 * The booking charge. A destination charge sends the driver's share to their
 * connected account and keeps the service fee and tax as the application fee.
 */
router.post("/stripeConnect/charge/destination/paymentintent", async (req, res) => {
  if (missingBodyFields(req, res,
      ["email", "amount", "application_fee", "payment_method_id", "return_url", "destination"])) {
    return;
  }
  try {
    const paymentIntent = await stripe().paymentIntents.create({
      amount: req.body.amount,
      currency: "usd",
      confirm: true,
      customer: req.body.customer_id,
      payment_method: req.body.payment_method_id,
      payment_method_types: ["card"],
      receipt_email: req.body.email,
      setup_future_usage: "on_session",
      return_url: req.body.return_url,
      application_fee_amount: req.body.application_fee,
      transfer_data: {destination: req.body.destination},
    });
    ok(res, "Payment Intent Created Successfully", paymentIntent);
  } catch (error) {
    serverError(res, error);
  }
});

/** Separate charge and transfer. Kept because the client still exposes it. */
router.post("/stripeConnect/charge/separate/paymentintent", async (req, res) => {
  if (missingBodyFields(req, res,
      ["customer_id", "email", "amount", "payment_method_id", "return_url", "destination", "transfer_group"])) {
    return;
  }
  try {
    const paymentIntent = await stripe().paymentIntents.create({
      amount: req.body.amount,
      currency: "usd",
      confirm: true,
      customer: req.body.customer_id,
      payment_method: req.body.payment_method_id,
      payment_method_types: ["card"],
      receipt_email: req.body.email,
      setup_future_usage: "off_session",
      return_url: req.body.return_url,
      on_behalf_of: req.body.destination,
      transfer_group: req.body.transfer_group,
    });
    ok(res, "Payment Intent Created Successfully", paymentIntent);
  } catch (error) {
    serverError(res, error);
  }
});

/** Releases a driver's Stripe balance to their bank. */
router.post("/stripeConnect/payout", async (req, res) => {
  if (missingBodyFields(req, res, ["amount", "account_id"])) return;
  try {
    // The old implementation returned an undefined `paymentIntent` variable
    // here, so this endpoint threw a ReferenceError on every success.
    const payout = await stripe().payouts.create(
        {amount: req.body.amount, currency: "usd"},
        {stripeAccount: req.body.account_id},
    );
    ok(res, "Payout created Successfully", payout);
  } catch (error) {
    serverError(res, error);
  }
});

/** Cancels a booking: refunds the passenger and claws back the driver's share. */
router.post("/stripeConnect/refundDestinationCharge", async (req, res) => {
  if (missingBodyFields(req, res, ["charge"])) return;
  try {
    const refund = await stripe().refunds.create({
      charge: req.body.charge,
      // Default to true — a cancelled ride should reverse the driver transfer
      // and the service fee, not just the passenger's card.
      reverse_transfer: req.body.reverse_transfer !== false,
      refund_application_fee: req.body.refund_application_fee !== false,
    });
    ok(res, "Refund processed Successfully", refund);
  } catch (error) {
    serverError(res, error);
  }
});

module.exports = router;
