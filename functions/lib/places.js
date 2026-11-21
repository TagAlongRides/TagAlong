const {defineSecret} = require("firebase-functions/params");

/**
 * Google Maps Platform key, held in Cloud Secret Manager.
 *
 * Server-side only, per docs/credentials.md: the app reaches Places and
 * Geocoding through the authenticated `api` function, so the key never ships
 * in the APK and can't be lifted to run up the bill. Restrict it in Cloud
 * Console to the Places API (New) and the Geocoding API.
 */
const googleMapsApiKey = defineSecret("GOOGLE_MAPS_API_KEY");

const AUTOCOMPLETE_URL = "https://places.googleapis.com/v1/places:autocomplete";
const DETAILS_URL = "https://places.googleapis.com/v1/places/";
const GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json";

/** Fields asked of Place Details. Each one is billed, so keep this short. */
const DETAILS_FIELD_MASK = "id,displayName,formattedAddress,addressComponents,location,types";

/**
 * Place types precise enough for a driver and passenger to meet at.
 *
 * Anything that resolves only to an area - a city, a zip code, a county, a
 * bare street - is too vague to post a ride with.
 */
const PRECISE_TYPES = new Set([
  "street_address", "premise", "subpremise", "establishment", "point_of_interest",
  "airport", "transit_station", "train_station", "bus_station", "parking",
  "university", "school", "intersection", "plus_code",
]);

/** Thrown for a request Google refused or answered unexpectedly. */
class PlacesError extends Error {
  constructor(message, status) {
    super(message);
    this.name = "PlacesError";
    this.status = status;
  }
}

/** True when a place with these types is somewhere you can be picked up. */
function isPrecise(types) {
  return Array.isArray(types) && types.some((t) => PRECISE_TYPES.has(t));
}

/**
 * Flattens address components from either API into the app's [Location].
 *
 * Places (New) spells them `longText`/`shortText`, Geocoding spells them
 * `long_name`/`short_name`; both carry `types`. Returns null when the place
 * isn't in a U.S. state, which every ride end must be.
 */
function toLocation({components, formattedAddress, name, placeId, lat, lng, types}) {
  const find = (type) => (components || []).find((c) => (c.types || []).includes(type));
  const long = (c) => (c ? (c.longText ?? c.long_name ?? "") : "");
  const short = (c) => (c ? (c.shortText ?? c.short_name ?? "") : "");

  const country = short(find("country"));
  const state = short(find("administrative_area_level_1"));
  if (country !== "US" || !state) return null;

  const city = long(find("locality")) || long(find("postal_town")) ||
    long(find("sublocality")) || long(find("administrative_area_level_3")) ||
    long(find("administrative_area_level_2"));

  const street = [long(find("street_number")), short(find("route"))].filter(Boolean).join(" ");
  const premise = long(find("premise"));
  const firstLine = (formattedAddress || "").split(",")[0].trim();
  const address = street || premise || name || firstLine;

  // A named place ("Dulles International Airport") reports its name apart
  // from the street; a plain street address has none. The app decides how to
  // show it - the ride board labels off-campus ends by city, not by name.
  const isNamedPlace = Boolean(name) && name !== address && name !== firstLine;

  return {
    place_id: placeId || null,
    address,
    city,
    state,
    zip: long(find("postal_code")),
    name: isNamedPlace ? name : null,
    formatted_address: formattedAddress || null,
    latitude: typeof lat === "number" ? lat : null,
    longitude: typeof lng === "number" ? lng : null,
    precise: isPrecise(types),
  };
}

async function readJson(response, what) {
  let body = null;
  try {
    body = await response.json();
  } catch (_) {
    // Fall through to the status check.
  }
  if (!response.ok) {
    const detail = body && body.error && body.error.message;
    throw new PlacesError(`${what} failed: ${detail || response.status}`, response.status);
  }
  return body || {};
}

/**
 * Suggestions for a partly typed address, U.S. only.
 *
 * `sessionToken` ties a run of keystrokes to the Place Details call that ends
 * it, so Google bills the whole search as one session.
 */
async function autocomplete({input, sessionToken}, {apiKey, fetchImpl = fetch}) {
  const response = await fetchImpl(AUTOCOMPLETE_URL, {
    method: "POST",
    headers: {"Content-Type": "application/json", "X-Goog-Api-Key": apiKey},
    body: JSON.stringify({
      input,
      sessionToken: sessionToken || undefined,
      includedRegionCodes: ["us"],
      languageCode: "en",
    }),
  });
  const body = await readJson(response, "Autocomplete");
  return (body.suggestions || [])
      .map((s) => s.placePrediction)
      .filter(Boolean)
      .map((p) => ({
        place_id: p.placeId,
        main_text: (p.structuredFormat && p.structuredFormat.mainText && p.structuredFormat.mainText.text) ||
          (p.text && p.text.text) || "",
        secondary_text: (p.structuredFormat && p.structuredFormat.secondaryText &&
          p.structuredFormat.secondaryText.text) || "",
      }));
}

/** The full address of a suggestion the driver picked. */
async function placeDetails({placeId, sessionToken}, {apiKey, fetchImpl = fetch}) {
  const url = new URL(DETAILS_URL + encodeURIComponent(placeId));
  if (sessionToken) url.searchParams.set("sessionToken", sessionToken);
  const response = await fetchImpl(url.toString(), {
    headers: {"X-Goog-Api-Key": apiKey, "X-Goog-FieldMask": DETAILS_FIELD_MASK},
  });
  const place = await readJson(response, "Place details");
  return toLocation({
    components: place.addressComponents,
    formattedAddress: place.formattedAddress,
    name: place.displayName && place.displayName.text,
    placeId: place.id,
    lat: place.location && place.location.latitude,
    lng: place.location && place.location.longitude,
    types: place.types,
  });
}

/**
 * Checks an address the driver typed without picking a suggestion.
 *
 * Answers one of:
 *  - `{status: "found", location, partial}` - Google placed it; `partial`
 *    means it had to guess, so the app should ask "did you mean".
 *  - `{status: "too_vague", location}` - it's a real area but not a spot to
 *    meet (a city, a zip, a whole street).
 *  - `{status: "not_found"}` - Google couldn't place it in the U.S.
 */
async function geocode({address}, {apiKey, fetchImpl = fetch}) {
  const url = new URL(GEOCODE_URL);
  url.searchParams.set("address", address);
  url.searchParams.set("components", "country:US");
  url.searchParams.set("key", apiKey);
  const response = await fetchImpl(url.toString());
  const body = await readJson(response, "Geocoding");

  if (body.status === "ZERO_RESULTS") return {status: "not_found"};
  if (body.status !== "OK") {
    throw new PlacesError(`Geocoding failed: ${body.status} ${body.error_message || ""}`.trim(), 502);
  }

  const result = body.results[0];
  const location = toLocation({
    components: result.address_components,
    formattedAddress: result.formatted_address,
    placeId: result.place_id,
    lat: result.geometry && result.geometry.location && result.geometry.location.lat,
    lng: result.geometry && result.geometry.location && result.geometry.location.lng,
    types: result.types,
  });
  if (!location) return {status: "not_found"};
  if (!location.precise) return {status: "too_vague", location};
  return {status: "found", location, partial: Boolean(result.partial_match)};
}

module.exports = {
  googleMapsApiKey, PlacesError, isPrecise, toLocation, autocomplete, placeDetails, geocode,
};
