import 'package:firebase_auth/firebase_auth.dart';
import 'package:tagalong/data/models/driver.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tagalong_user_new.g.dart';

/// Represents the [TagAlongUserNew] data model.
///
/// Run `flutter pub run build_runner build --delete-conflicting-outputs` for one-time generation.
@JsonSerializable()
class TagAlongUserNew {
  String id;                          // User.uid
  String providerId;                  // User.providerData[0].providerId
  bool isEmailVerified;               // User.emailVerified   --> Proves [TagAlongUserNew] is "Registered"
  bool isRegistered = false;
  String? name;
  String? institution;
  String? emailAddress;
  String? password;
  // TODO: need to have verification for this as well eventually..
  // String phoneNumber;
  int? signUpTime;
  String? graduationYear;
  Driver? driverData;


  /// Initializes an [TagAlongUserNew]
  ///
  ///
  TagAlongUserNew({
    required this.id,
    required this.isEmailVerified,
    required this.providerId,
    this.name,
    this.institution,
    this.signUpTime,
    this.emailAddress,
    this.password,
    this.graduationYear,
    this.driverData,
  });

  TagAlongUserNew.fromFireBaseUser(User user):
    id = user.uid,
    isEmailVerified = user.emailVerified,
    providerId = user.providerData[0].providerId;

  factory TagAlongUserNew.fromJson(Map<String, dynamic> json) => _$TagAlongUserNewFromJson(json);

  Map<String, dynamic> toJson() => _$TagAlongUserNewToJson(this);
}