// import 'package:tagalong/data/models/driver.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'tagalong_user.g.dart';

/// Represents the [TagAlongUser] data model.
///
/// Run `flutter pub run build_runner build --delete-conflicting-outputs` for one-time generation.
@JsonSerializable()
class TagAlongUser {

  // REQUIRED Fields
  String id;                          // User.uid
  String providerId;                  // User.providerData[0].providerId
  bool isRegistered = false;
  // bool isEmailVerified;            // User.emailVerified  --> Proves [TagAlongUser] is "Registered"

  // OPTIONAL Fields
  String? stripeAccountId;
  String? stripeCustomerId;
  String? profilePictureUrl;
  String? name;
  String? institution;
  String? emailAddress;               // School email, not provider email
  String? password;
  String? graduationYear;

  // TODO: need to have verification for this as well eventually. Need Mike's direction
  // String phoneNumber;

  // TODO: Need to create DriverRepository
  //Driver? driverData;


  /// Initializes an [TagAlongUser]
  ///
  /// This constructor is used for creating a brand new TagAlongUser, therefore
  /// the user is NOT registered (isRegistered) OR verified (isEmailVerified)
  TagAlongUser({
    required this.id,
    required this.providerId,
    this.stripeAccountId,
    this.stripeCustomerId,
    this.name,
    this.institution,
    this.emailAddress,
    this.password,
    this.graduationYear,
    // this.driverData,
  });

  /// Returns a [TagAlongUser] from a FirebaseAuth [User] instance
  ///
  /// Should not be used public unless registration phase.
  TagAlongUser.fromFireBaseUser(User user):
    id = user.uid,
    providerId = user.providerData[0].providerId;

  factory TagAlongUser.fromJson(Map<String, dynamic> json) => _$TagAlongUserFromJson(json);

  Map<String, dynamic> toJson() => _$TagAlongUserToJson(this);
}