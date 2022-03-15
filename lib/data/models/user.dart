import 'package:tagalong/data/models/driver.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tagalong/data/models/ta_data_model.dart';
import 'package:tagalong/util/user_data.dart';

/// A user model containing pertinent data
class TagAlongUser implements TADataModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  String institution;
  String firstName;
  String lastName;
  String? graduationYear;
  String phoneNumber;
  String emailAddress;
  Driver? driverData;
  bool registered;
  String signInMethod;


  /// Initializes an Unregistered User.
  ///
  /// The minimum definition for a valid user requires an ID, a creation date,
  /// and a sign-in method. This is used when a user successfully logs in with
  /// Facebook, but never completes user registration.
  TagAlongUser({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.signInMethod=SignInMethod.FACEBOOK,
    this.institution="",
    this.firstName="",
    this.lastName="",
    this.phoneNumber="",
    this.emailAddress="",
    this.registered=false,
    this.graduationYear=null,
    this.driverData=null
  });

  /// A Map<String, dynamic> into a [TagAlongUser] instance.
  ///
  /// Assumes that [json] data is always from Firebase, therefore
  /// `created_at` may be a [Timestamp] or [Datetime],
  /// since Firebase stores [DateTime] as [TimeStamp]
  factory TagAlongUser.fromJson(Map<String, dynamic> json) {
    var createdAt = json['created_at'];
    if (createdAt == null) {
      throw UnsupportedError('Invalid - createdAt is $createdAt');
    }
    else if (createdAt is Timestamp) {
      createdAt = createdAt.toDate();
    }
    var updatedAt = json['updated_at'];
    if (updatedAt == null) {
      throw UnsupportedError('Invalid - updatedAt is $updatedAt');
    }
    else if (updatedAt is Timestamp) {
      updatedAt = updatedAt.toDate();
    }
    final id = json['id'] as String?;
    if (id == null) {
      throw UnsupportedError('Invalid - id is $id');
    }
    final institution = json['institution'] as String?;
    if (institution == null) {
      throw UnsupportedError('Invalid - institution is $institution');
    }
    final firstName = json['first_name'] as String?;
    if (firstName == null) {
      throw UnsupportedError('Invalid - firstName is $firstName');
    }
    final lastName = json['last_name'] as String?;
    if (lastName == null) {
      throw UnsupportedError('Invalid - lastName is $lastName');
    }
    final signInMethod = json['sign_in_method'] as String?;
    if (signInMethod == null) {
      throw UnsupportedError('Invalid - signInMethod is $signInMethod');
    }
    final phoneNumber = json['phone_number'] as String?;
    if (phoneNumber == null) {
      throw UnsupportedError('Invalid - phoneNumber is $phoneNumber');
    }
    final emailAddress = json['email_address'] as String?;
    if (emailAddress == null) {
      throw UnsupportedError('Invalid - emailAddress is $emailAddress');
    }
    var graduationYear = json['graduation_year'] as String?;
    final registered = json['is_registered'] ?? false;
    var driverData = json['driver_data'];
    if (driverData != null) {
      driverData = Driver.fromJson(driverData);
    }

    return TagAlongUser(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      signInMethod: signInMethod,
      institution: institution,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      emailAddress: emailAddress,
      registered: registered,
      graduationYear: graduationYear,
      driverData: driverData
    );

  }
  /// A named constructor to create a [TagAlongUser] from a Map<String, dynamic>
  // TagAlongUser.fromJson(Map<String, dynamic> json):
  //   this.id = json['id'],
  //   this.createdAt = json['created'].toDate(),
  //   this.updatedAt = json['last_updated'].toDate(),
  //   this.institution = json['institution'],
  //   this.firstName = json['first_name'],
  //   this.lastName = json['last_name'],
  //   this.signInMethod = json['sign_in_method'],
  //   this.graduationYear = json['grad_year'],
  //   this.registered = json['is_registered'],
  //   this.phoneNumber = json['phone_number'],
  //   this.emailAddress = json['email_address'] {
  //   if (json['driver_data'] != null) {
  //     this.driverData = Driver.fromJson(json['driver_data']);
  //   }
  // }


  // /// Registers a User.
  // ///
  // /// Fills in the fields of a User that were left undefined at initialization.
  // void registerUser(
  //     String firstName,
  //     String lastName,
  //     String institution,
  //     String graduationYear,
  //     String phoneNumber,
  //     String emailAddress) {
  //   firstName = firstName;
  //   lastName = lastName;
  //   institution = institution;
  //   graduationYear = graduationYear;
  //   phoneNumber = phoneNumber;
  //   emailAddress = emailAddress;
  //   registered = true;
  //   driverData = null;
  //
  //   // TODO: Probably don't want to rely on system time like this...
  //   updatedAt = DateTime.now();
  // }

  /// Updates this instance's [TagAlongUser] only if that data field
  /// exists within [data], and only updates the TagAlongUserViewModel's user instance.
  /// It should be assumed that `created_at` and `updated_at` are Timestamps
  void updateTagAlongUser(Map<String, dynamic> data) {
    id = data['id'] ?? id;
    createdAt = data['created_at']?.toDate() ?? createdAt;
    updatedAt = data['updated_at']?.toDate() ?? updatedAt;
    signInMethod = data['sign_in_method'] ?? signInMethod;
    registered = data['is_registered'] ?? registered;
    firstName = data['first_name'] ?? firstName;
    lastName = data['last_name'] ?? lastName;
    institution = data['institution'] ?? institution;
    graduationYear = data['graduation_year'] ?? graduationYear;
    phoneNumber = data['phone_number'] ?? phoneNumber;
    emailAddress = data['email_address'] ?? emailAddress;
    driverData = data['driver_data'] ?? driverData;
  }

  /// Convert a User object to a map that respects its values' types.
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sign_in_method': signInMethod,
      'is_registered': registered,
      'first_name': firstName,
      'last_name': lastName,
      'institution': institution,
      'graduation_year': graduationYear,
      'phone_number': phoneNumber,
      'email_address': emailAddress,
      'driver_data': driverData?.toJson()
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

}
