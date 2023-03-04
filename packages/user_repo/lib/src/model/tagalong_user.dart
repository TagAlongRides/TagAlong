// import 'package:tagalong/data/models/driver.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'tagalong_user.g.dart';

/// Represents the [TagAlongUser] data model.
///
/// Run `flutter pub run build_runner build --delete-conflicting-outputs` for one-time generation.
@JsonSerializable()
class TagAlongUser {
  String id;                          // User.uid
  String providerId;                  // User.providerData[0].providerId
  bool isEmailVerified;               // User.emailVerified  --> Proves [TagAlongUser] is "Registered"
  bool isRegistered = false;
  String? name;
  String? institution;
  String? emailAddress;               // School email, not provider email
  String? password;
  // TODO: need to have verification for this as well eventually..
  // String phoneNumber;
  int? signUpTime;
  String? graduationYear;
  //Driver? driverData;


  /// Initializes an [TagAlongUser]
  ///
  /// This constructor is used for creating a brand new TagAlongUser, therefore
  /// the user is NOT registered (isRegistered) OR verified (isEmailVerified)
  TagAlongUser({
    required this.id,
    required this.isEmailVerified,
    required this.providerId,
    this.name,
    this.institution,
    this.signUpTime,
    this.emailAddress,
    this.password,
    this.graduationYear,
    // this.driverData,
  });

  TagAlongUser.fromFireBaseUser(User user):
    id = user.uid,
    isEmailVerified = user.emailVerified,
    providerId = user.providerData[0].providerId;

  factory TagAlongUser.fromJson(Map<String, dynamic> json) => _$TagAlongUserFromJson(json);

  Map<String, dynamic> toJson() => _$TagAlongUserToJson(this);
}