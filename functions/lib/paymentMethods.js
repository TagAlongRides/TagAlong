/**
 * The signed-in passenger's saved cards: list, save, remove and pick a
 * default.
 *
 * Every function here works on the customer that belongs to the caller, found
 * from their Firebase uid, never on a customer id the app sends. The older
 * `/customer/:id` and `/getPaymentMethods/:customer_id` routes take the id
 * from the URL, so any signed-in user could read anyone's cards; these do not
 * repeat that.
 *
 * Stripe and Firestore are passed in, so the rules can be tested without
 * either.
 */

/** A request the caller is not allowed to make, answered as a 403. */
class ForbiddenError extends Error {
  constructor(message) {
    super(message);
    this.name = "ForbiddenError";
    this.statusCode = 403;
  }
}

/** Reads the id a value may be an expanded object or a bare id. */
function idOf(value) {
  if (!value) return null;
  return typeof value === "string" ? value : value.id || null;
}

/**
 * The caller's Stripe customer id, creating the customer on first use.
 *
 * Registration normally creates one, but accounts made before that, or whose
 * registration call failed, have an empty `stripe_customer_id`. Saving a card
 * is exactly when they need one, so it is made here rather than failing.
 *
 * @param {object} deps `{stripe, users}` where `users` is the Firestore
 *   `users` collection reference.
 * @param {string} uid The caller's Firebase uid.
 */
async function customerIdFor({stripe, users}, uid) {
  const ref = users.doc(uid);
  const snapshot = await ref.get();
  if (!snapshot.exists) {
    throw new ForbiddenError("No TagAlong account for this user");
  }
  const user = snapshot.data();
  if (user.stripe_customer_id) return user.stripe_customer_id;

  const name = [user.first_name, user.last_name].filter(Boolean).join(" ");
  const customer = await stripe.customers.create({
    name: name || undefined,
    email: user.email_address || undefined,
    metadata: {firebase_uid: uid},
  });
  await ref.update({stripe_customer_id: customer.id});
  return customer.id;
}

/**
 * The customer's cards, plus which one is their default.
 *
 * Returns the same list shape Stripe sends (and the older endpoint returned),
 * with `default_payment_method` added.
 */
async function listCards(stripe, customerId) {
  const [cards, customer] = await Promise.all([
    stripe.paymentMethods.list({customer: customerId, type: "card"}),
    stripe.customers.retrieve(customerId),
  ]);
  const settings = customer.invoice_settings || {};
  return {...cards, default_payment_method: idOf(settings.default_payment_method)};
}

/**
 * A SetupIntent the app confirms with the card form, which saves the card to
 * the customer without charging it. Stripe runs any check the bank asks for
 * (3-D Secure) as part of confirming it.
 */
async function createSetupIntent(stripe, customerId) {
  const intent = await stripe.setupIntents.create({
    customer: customerId,
    payment_method_types: ["card"],
    // The card is charged later, when the passenger books, without them
    // present at the moment the charge is made.
    usage: "off_session",
  });
  return {id: intent.id, client_secret: intent.client_secret};
}

/** Throws unless `paymentMethodId` is a card saved to `customerId`. */
async function requireOwnCard(stripe, customerId, paymentMethodId) {
  let method;
  try {
    method = await stripe.paymentMethods.retrieve(paymentMethodId);
  } catch (error) {
    // An id that doesn't exist and one that belongs to someone else read the
    // same from outside, so the caller can't probe for other people's cards.
    if (error && error.statusCode === 404) throw new ForbiddenError("That card isn't saved to your account");
    throw error;
  }
  if (idOf(method.customer) !== customerId) {
    throw new ForbiddenError("That card isn't saved to your account");
  }
  return method;
}

/** Makes one of the customer's cards their default. */
async function setDefaultCard(stripe, customerId, paymentMethodId) {
  await requireOwnCard(stripe, customerId, paymentMethodId);
  await stripe.customers.update(customerId, {
    invoice_settings: {default_payment_method: paymentMethodId},
  });
  return {default_payment_method: paymentMethodId};
}

/**
 * Removes a card from the customer.
 *
 * Detaching a card clears it as the default too, so the customer is left
 * with no default; the app then treats its first card as the one to use.
 * Bookings already paid for are unaffected: their charges are complete.
 */
async function removeCard(stripe, customerId, paymentMethodId) {
  await requireOwnCard(stripe, customerId, paymentMethodId);
  await stripe.paymentMethods.detach(paymentMethodId);
  return {id: paymentMethodId, detached: true};
}

module.exports = {
  ForbiddenError,
  customerIdFor,
  listCards,
  createSetupIntent,
  setDefaultCard,
  removeCard,
};
