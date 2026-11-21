const test = require("node:test");
const assert = require("node:assert");

const {toLocation, isPrecise, autocomplete, placeDetails, geocode, PlacesError} = require("../lib/places");

/** A fetch stand-in that records the request and answers with [body]. */
function fakeFetch(body, {ok = true, status = 200} = {}) {
  const calls = [];
  const impl = async (url, init) => {
    calls.push({url, init});
    return {ok, status, json: async () => body};
  };
  impl.calls = calls;
  return impl;
}

const placesComponents = [
  {longText: "1600", shortText: "1600", types: ["street_number"]},
  {longText: "Amphitheatre Parkway", shortText: "Amphitheatre Pkwy", types: ["route"]},
  {longText: "Mountain View", shortText: "Mountain View", types: ["locality", "political"]},
  {longText: "California", shortText: "CA", types: ["administrative_area_level_1", "political"]},
  {longText: "United States", shortText: "US", types: ["country", "political"]},
  {longText: "94043", shortText: "94043", types: ["postal_code"]},
];

test("a street address flattens to address, city, state and zip with no label", () => {
  const loc = toLocation({
    components: placesComponents,
    formattedAddress: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    name: "1600 Amphitheatre Pkwy",
    placeId: "abc",
    lat: 37.42, lng: -122.08,
    types: ["street_address"],
  });
  assert.deepStrictEqual(loc, {
    place_id: "abc",
    address: "1600 Amphitheatre Pkwy",
    city: "Mountain View",
    state: "CA",
    zip: "94043",
    name: null,
    formatted_address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    latitude: 37.42,
    longitude: -122.08,
    precise: true,
  });
});

test("a named place reports its name apart from the street", () => {
  const loc = toLocation({
    components: placesComponents,
    formattedAddress: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    name: "Googleplex",
    types: ["establishment", "point_of_interest"],
  });
  assert.strictEqual(loc.name, "Googleplex");
  assert.strictEqual(loc.address, "1600 Amphitheatre Pkwy");
});

test("a place with no street number uses its name as the address line", () => {
  const loc = toLocation({
    components: placesComponents.filter((c) => !c.types.includes("street_number") && !c.types.includes("route")),
    formattedAddress: "Mountain View, CA 94043, USA",
    name: "Shoreline Lake",
    types: ["park", "point_of_interest"],
  });
  assert.strictEqual(loc.address, "Shoreline Lake");
  assert.strictEqual(loc.name, null);
});

test("Geocoding's long_name/short_name components read the same", () => {
  const loc = toLocation({
    components: placesComponents.map((c) => ({long_name: c.longText, short_name: c.shortText, types: c.types})),
    formattedAddress: "x",
    types: ["street_address"],
  });
  assert.strictEqual(loc.state, "CA");
  assert.strictEqual(loc.city, "Mountain View");
});

test("a place outside the U.S. is rejected", () => {
  const loc = toLocation({
    components: [
      {longText: "Toronto", shortText: "Toronto", types: ["locality"]},
      {longText: "Ontario", shortText: "ON", types: ["administrative_area_level_1"]},
      {longText: "Canada", shortText: "CA", types: ["country"]},
    ],
    types: ["locality"],
  });
  assert.strictEqual(loc, null);
});

test("cities, zips and bare streets are not precise; addresses and places are", () => {
  assert.strictEqual(isPrecise(["locality", "political"]), false);
  assert.strictEqual(isPrecise(["postal_code"]), false);
  assert.strictEqual(isPrecise(["route"]), false);
  assert.strictEqual(isPrecise(undefined), false);
  assert.strictEqual(isPrecise(["street_address"]), true);
  assert.strictEqual(isPrecise(["airport", "point_of_interest"]), true);
});

test("autocomplete sends the key in a header, restricts to the U.S. and maps suggestions", async () => {
  const fetchImpl = fakeFetch({
    suggestions: [
      {placePrediction: {
        placeId: "p1",
        text: {text: "Dulles Airport, VA, USA"},
        structuredFormat: {mainText: {text: "Dulles Airport"}, secondaryText: {text: "VA, USA"}},
      }},
      {queryPrediction: {text: {text: "dulles pizza"}}},
    ],
  });
  const out = await autocomplete({input: "dull", sessionToken: "s1"}, {apiKey: "k", fetchImpl});
  assert.deepStrictEqual(out, [{place_id: "p1", main_text: "Dulles Airport", secondary_text: "VA, USA"}]);
  const {init} = fetchImpl.calls[0];
  assert.strictEqual(init.headers["X-Goog-Api-Key"], "k");
  const sent = JSON.parse(init.body);
  assert.deepStrictEqual(sent.includedRegionCodes, ["us"]);
  assert.strictEqual(sent.sessionToken, "s1");
});

test("place details asks only for the fields it uses and passes the session", async () => {
  const fetchImpl = fakeFetch({
    id: "p1", displayName: {text: "1600 Amphitheatre Pkwy"},
    formattedAddress: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    addressComponents: placesComponents, location: {latitude: 1, longitude: 2}, types: ["street_address"],
  });
  const loc = await placeDetails({placeId: "p1", sessionToken: "s1"}, {apiKey: "k", fetchImpl});
  assert.strictEqual(loc.zip, "94043");
  assert.strictEqual(loc.latitude, 1);
  const {url, init} = fetchImpl.calls[0];
  assert.match(url, /places\/p1\?sessionToken=s1$/);
  assert.strictEqual(init.headers["X-Goog-FieldMask"], "id,displayName,formattedAddress,addressComponents,location,types");
});

test("an upstream error becomes a PlacesError with Google's message", async () => {
  const fetchImpl = fakeFetch({error: {message: "API key not valid"}}, {ok: false, status: 403});
  await assert.rejects(
      autocomplete({input: "abc"}, {apiKey: "k", fetchImpl}),
      (e) => e instanceof PlacesError && /API key not valid/.test(e.message));
});

const geocodeResult = (types, extra = {}) => ({
  status: "OK",
  results: [{
    address_components: placesComponents.map((c) => ({long_name: c.longText, short_name: c.shortText, types: c.types})),
    formatted_address: "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
    place_id: "g1",
    geometry: {location: {lat: 3, lng: 4}},
    types,
    ...extra,
  }],
});

test("geocode finds a precise address", async () => {
  const out = await geocode({address: "1600 amphitheatre"}, {apiKey: "k", fetchImpl: fakeFetch(geocodeResult(["street_address"]))});
  assert.strictEqual(out.status, "found");
  assert.strictEqual(out.partial, false);
  assert.strictEqual(out.location.latitude, 3);
});

test("geocode flags a partial match so the app can ask 'did you mean'", async () => {
  const out = await geocode({address: "1600 amphitheater"},
      {apiKey: "k", fetchImpl: fakeFetch(geocodeResult(["street_address"], {partial_match: true}))});
  assert.strictEqual(out.partial, true);
});

test("geocode calls a city too vague", async () => {
  const out = await geocode({address: "mountain view"}, {apiKey: "k", fetchImpl: fakeFetch(geocodeResult(["locality", "political"]))});
  assert.strictEqual(out.status, "too_vague");
});

test("geocode reports nothing found, and restricts to the U.S.", async () => {
  const fetchImpl = fakeFetch({status: "ZERO_RESULTS", results: []});
  const out = await geocode({address: "asdfgh"}, {apiKey: "k", fetchImpl});
  assert.deepStrictEqual(out, {status: "not_found"});
  assert.match(fetchImpl.calls[0].url, /components=country%3AUS/);
});

test("a Geocoding error status throws rather than reading as not found", async () => {
  await assert.rejects(
      geocode({address: "x"}, {apiKey: "k", fetchImpl: fakeFetch({status: "REQUEST_DENIED", error_message: "no"})}),
      PlacesError);
});
