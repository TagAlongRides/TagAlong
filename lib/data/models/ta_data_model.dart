/// An interface that all data models within the TagAlong Application
/// should implement.
///
/// More than its usefulness for inheritance & polymorphism, its main objective
/// is to establish a known contract among all TagAlong data models.

class TADataModel {

  TADataModel();

  /// Returns a Map representing the given data model
  Map<String, dynamic> toJson() => {};

  /// Constructs an instance using the given model's constructor from a Map.
  /// It should also validate the data to make sure if null if returned for
  /// non-nullable types, then an [UnsupportedError] should occur.
  factory TADataModel.fromJson(Map<String, dynamic> json) => TADataModel();

  /// Returns a stringified version of the data model
  @override
  String toString() => '';
}