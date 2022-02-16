

/// [Vehicle] Data model.
class Vehicle {

  DateTime _createdAt;
  String _make;
  String _model;
  String _year;
  String _color;

  Vehicle(
      required this._createdAt,
      required this._make,
      this._model,
      this._year,
      this._color
      );

  /// A [Vehicle] instance into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'created_at': _createdAt,
      'make': _make,
      'model': _model,
      'year': _year,
      'color': _color
    };
  }

  /// A Map<String, dynamic> into a [Vehicle] instance
  Vehicle.fromJson(Map<String, dynamic> json) {
    _createdAt = json['created_at'].toDate();
    _make = json['make'];
    _model = json['model'];
    _year = json['year'];
    _color = json['color'];
  }
}