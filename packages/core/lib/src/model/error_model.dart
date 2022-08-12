// To parse this JSON data, do
//
//     final errorModel = errorModelFromJson(jsonString);

import 'dart:convert';

ErrorModel errorModelFromJson(String str) =>
    ErrorModel.fromJson(json.decode(str));

String errorModelToJson(ErrorModel data) => json.encode(data.toJson());

class ErrorModel {
  ErrorModel({
    required this.status,
    required this.success,
    required this.message,
  });

  final int status;
  final bool success;
  final String message;

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
        status: json["status"],
        success: json["success"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "success": success,
        "message": message,
      };

  /// Error in case Firebase operation have some error
  /// Status code 600 -  custom
  /// success - false
  factory ErrorModel.firebaseError(String message) {
    return ErrorModel(status: 600, success: false, message: message);
  }
}
