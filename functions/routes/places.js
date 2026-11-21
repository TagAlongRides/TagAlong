const express = require("express");
const logger = require("firebase-functions/logger");
const {ok, badRequest, BaseResponseModel} = require("../lib/response");
const {googleMapsApiKey, autocomplete, placeDetails, geocode} = require("../lib/places");

/*
 * Address lookup for the Offer Ride flow, so a ride's off-campus end is a
 * place Google can find rather than whatever was typed into four boxes.
 * Mounted behind requireAuth: each call is billed to TagAlong.
 */

const router = express.Router();

const MAX_INPUT = 200;

const deps = () => ({apiKey: googleMapsApiKey.value()});

function readText(value) {
  return typeof value === "string" ? value.trim().slice(0, MAX_INPUT) : "";
}

function fail(res, error) {
  logger.error("Places request failed", {detail: error && error.message, upstream: error && error.status});
  res.status(502).send(new BaseResponseModel(502, false, "Address lookup is unavailable right now"));
}

/** GET /autocomplete?input=...&sessionToken=... */
router.get("/autocomplete", async (req, res) => {
  const input = readText(req.query.input);
  if (input.length < 3) return ok(res, "Suggestions", []);
  try {
    ok(res, "Suggestions", await autocomplete({input, sessionToken: readText(req.query.sessionToken)}, deps()));
  } catch (error) {
    fail(res, error);
  }
});

/** GET /details/:placeId?sessionToken=... */
router.get("/details/:placeId", async (req, res) => {
  const placeId = readText(req.params.placeId);
  if (!placeId) return badRequest(res, "Missing placeId");
  try {
    const location = await placeDetails({placeId, sessionToken: readText(req.query.sessionToken)}, deps());
    if (!location) return badRequest(res, "That place isn't in the U.S.");
    ok(res, "Place", location);
  } catch (error) {
    fail(res, error);
  }
});

/** GET /geocode?address=... */
router.get("/geocode", async (req, res) => {
  const address = readText(req.query.address);
  if (!address) return badRequest(res, "Missing address");
  try {
    ok(res, "Geocode", await geocode({address}, deps()));
  } catch (error) {
    fail(res, error);
  }
});

module.exports = router;
