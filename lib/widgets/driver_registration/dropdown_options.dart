/// The options for a vehicle dropdown, with [current] added if it is missing.
///
/// A driver's saved make and model come from whatever list was in use when
/// they registered. Makes and models used to come from an API; they now come
/// from the bundled `assets/vehicles.json`, which is smaller, so a saved car
/// such as an AMC Matador from 2023 may not be in it. A `DropdownButton` whose
/// value matches none of its items fails an assertion and the registration
/// form becomes an error screen, so the saved value is kept as an option
/// instead. It goes first, where the driver will see what they had.
List<String> withCurrent(List<String> options, String? current) {
  if (current == null || current.isEmpty || options.contains(current)) return options;
  return [current, ...options];
}
