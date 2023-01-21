import 'package:tagalong/data/models/driver.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tagalong_user_new.g.dart';

/// Represents the [TagAlongUserNew] data model.
@JsonSerializable()
class TagAlongUserNew {
  String id;
  String name;
  String signUpMethod;
  String institution;
  String emailAddress;
  // TODO: need to have verification for this as well eventually..
  // String phoneNumber;
  int signUpTime;
  bool isEmailVerified = false;
  String? password;
  String? graduationYear;
  Driver? driverData;


  /// Initializes an [TagAlongUserNew]
  ///
  ///
  TagAlongUserNew({
    required this.id,
    required this.name,
    required this.signUpMethod,
    required this.institution,
    required this.signUpTime,
    required this.emailAddress,
    this.password,
    this.graduationYear,
    this.driverData,
    this.isEmailVerified = false,
  });

  factory TagAlongUserNew.fromJson(Map<String, dynamic> json) => _$TagAlongUserNewFromJson(json);

  Map<String, dynamic> toJson() => _$TagAlongUserNewToJson(this);
}