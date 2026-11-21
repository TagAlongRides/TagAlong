const logger = require("firebase-functions/logger");

/**
 * The response envelope every endpoint returns.
 *
 * Shape is fixed by the Flutter client — `packages/stripe_repo` parses
 * `status` / `success` / `message` / `data` — so it must not change.
 */
class BaseResponseModel {
  constructor(status, success, message, data) {
    this.status = status;
    this.success = success;
    this.message = message;
    this.data = data;
  }
}

/** 200 with a payload. */
const ok = (res, message, data) =>
  res.status(200).send(new BaseResponseModel(200, true, message, data));

/** 400 for a missing or unusable request parameter. */
const badRequest = (res, message) =>
  res.status(400).send(new BaseResponseModel(400, false, message));

/**
 * Answers a request whose handler threw.
 *
 * A Stripe 400 (`invalid_request_error`) means the request we built was wrong,
 * so it is answered as a 400 carrying Stripe's message. Anything else is a 500.
 * Before this, a rejected parameter came back as an opaque "Request failed"
 * 500 that looked identical to an outage.
 *
 * Note the old backend sent `success: true` on its 500s, which made failures
 * hard to distinguish client-side. This reports them honestly.
 */
const serverError = (res, error) => {
  const status = isStripeBadRequest(error) ? 400 : 500;
  // Logged as well as returned. Without this a failing route produced a 500
  // with no entry in Cloud Logging at all, so the only evidence was an
  // ERROR-severity request log with an empty message.
  // Deliberately not using `message` as a key: firebase-functions/logger
  // treats it as the log's own message and overwrites it with a stack trace,
  // which hid the Stripe error this was added to surface.
  logger.error(status === 400 ? "Stripe rejected the request" : "Request failed", {
    status,
    detail: error && error.message,
    stripeType: error && error.type,
    stripeCode: error && error.code,
    stripeParam: error && error.param,
    stripeRequestId: error && error.requestId,
  });
  if (status === 400) {
    const param = error.param ? ` (${error.param})` : "";
    return res.status(400).send(new BaseResponseModel(400, false, `${error.message}${param}`));
  }
  return res.status(500).send(new BaseResponseModel(500, false, `Something went wrong: ${error}`));
};

/** True for a Stripe error that Stripe itself answered with HTTP 400. */
function isStripeBadRequest(error) {
  return Boolean(error) &&
    typeof error.type === "string" && error.type.startsWith("Stripe") &&
    error.statusCode === 400;
}

/**
 * Rejects the request unless every named field is present on the body.
 * Returns true when the request has already been answered.
 */
function missingBodyFields(req, res, fields) {
  for (const field of fields) {
    if (req.body[field] === undefined || req.body[field] === null || req.body[field] === "") {
      badRequest(res, `Body Params missing - ${field}`);
      return true;
    }
  }
  return false;
}

module.exports = {BaseResponseModel, ok, badRequest, serverError, missingBodyFields};
