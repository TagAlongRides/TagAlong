import 'package:tagalong/util/user_data.dart';

/// A user model containing pertinent data
class User {
  String id = "";
  DateTime createdAt = DateTime(0);
  DateTime updatedAt = DateTime(0);
  SignInMethod signInMethod = SignInMethod.invalid;
  bool registered = false;
  String firstName = "";
  String lastName = "";
  Institution institution = Institution.invalid;
  Affiliation affiliation = Affiliation.invalid;
  DateTime graduationYear = DateTime(0);
  String phoneNumber = "";
  String emailAddress = "";

  /// Initializes a User.
  ///
  /// The minimum definition for a valid user requires an ID, a creation date,
  /// and a sign-in method.
  User(this.id, this.createdAt, this.signInMethod) {
    updatedAt = createdAt;
    registered = false;
  }

  /// Registers a User.
  ///
  /// Fills in the fields of a User that were left undefined at initialization.
  void registerUser(
      String firstName,
      String lastName,
      Institution institution,
      Affiliation affiliation,
      DateTime graduationYear,
      String phoneNumber,
      String emailAddress) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.institution = institution;
    this.affiliation = affiliation;
    this.graduationYear = graduationYear;
    this.phoneNumber = phoneNumber;
    this.emailAddress = emailAddress;

    registered = true;
    updatedAt = DateTime.now();
  }

  /// Flag indicating whether a user is registered or not.
  bool isRegistered() {
    return registered;
  }

  /// Convert a User object to a String map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created': createdAt.toString(),
      'last_updated': updatedAt.toString(),
      'sign_in_method': signInMethod.name,
      'is_registered': registered.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'institution': institution.name,
      'affiliation': affiliation.name,
      'grad_year': graduationYear.toString(),
      'phone_number': phoneNumber,
      'email_address': emailAddress
    };
  }
}
