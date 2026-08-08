const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const {BaseResponseModel} = require("./response");

/**
 * Requires a valid Firebase ID token on every request.
 *
 * The previous backend had this switched off ("Remove the auth header for
 * testing"), which left payment intents, refunds, transfers and payouts
 * callable by anyone who read the endpoint URL out of the shipped app. It
 * stays on.
 *
 * On success the decoded token is attached as `req.user`.
 */
async function requireAuth(req, res, next) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith("Bearer ")) {
    res.status(401).send(new BaseResponseModel(401, false, "Missing or malformed Authorization header"));
    return;
  }

  const idToken = header.substring("Bearer ".length).trim();
  if (!idToken) {
    res.status(401).send(new BaseResponseModel(401, false, "Missing bearer token"));
    return;
  }

  try {
    // checkRevoked: true so a signed-out or disabled user is rejected rather
    // than riding on a token that hasn't expired yet.
    req.user = await admin.auth().verifyIdToken(idToken, true);
    next();
  } catch (error) {
    logger.warn("Rejected request with invalid ID token", {reason: error.code || error.message});
    res.status(401).send(new BaseResponseModel(401, false, "Invalid or expired credentials"));
  }
}

module.exports = {requireAuth};
