/// [Vehicle] Data model.
class Vehicle {

  final String vehicleId;   // UUID
  final DateTime createdAt;
  final String make;
  final String model;
  final String year;
  final String color;

  Vehicle({
    required this.createdAt,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.vehicleId
  });

  /// A Map<String, dynamic> into a [Vehicle] instance
  Vehicle.fromJson(Map<String, dynamic> json):
    vehicleId = json['vehicle_id'],
    createdAt = json['created_at'].toDate(),
    make = json['make'],
    model = json['model'],
    year = json['year'],
    color = json['color'];

  /// A [Vehicle] instance into a Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'created_at': createdAt,
      'make': make,
      'model': model,
      'year': year,
      'color': color
    };
  }

  @override
  String toString() {
    return 'Vehicle $vehicleId - \n'
        '${toJson().toString()}';
  }

}