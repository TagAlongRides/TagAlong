import 'package:tagalong/util/user_data.dart';

/// A user model containing pertinent data
class User {
  final String _id;
  final DateTime _createdAt;
  DateTime _updatedAt = DateTime(0);
  final SignInMethod _signInMethod;
  bool _registered = false;
  String _firstName = "";
  String _lastName = "";
  Institution _institution = Institution.invalid;
  Affiliation _affiliation = Affiliation.invalid;
  DateTime _graduationYear = DateTime(0);
  String _phoneNumber = "";
  String _emailAddress = "";

  /// Initializes a User.
  ///
  /// The minimum definition for a valid user requires an ID, a creation date,
  /// and a sign-in method.
  User(this._id, this._createdAt, this._signInMethod) {
    _updatedAt = _createdAt;
    _registered = false;
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
    _firstName = firstName;
    _lastName = lastName;
    _institution = institution;
    _affiliation = affiliation;
    _graduationYear = graduationYear;
    _phoneNumber = phoneNumber;
    _emailAddress = emailAddress;

    _registered = true;
    // TODO: Probably don't want to rely on system time like this...
    _updatedAt = DateTime.now();
  }

  /// Flag indicating whether a user is registered or not.
  bool isRegistered() {
    return _registered;
  }

  /// Convert a User object to a String map.
  Map<String, String?> toMap() {
    // TODO: the key values below should not be hardcoded, figure out a more
    //  central location for them
    return {
      'id': _id,
      'created': _createdAt.toString(),
      'last_updated': _updatedAt.toString(),
      'sign_in_method': _signInMethod.name,
      'is_registered': _registered.toString(),
      'first_name': _firstName,
      'last_name': _lastName,
      'institution': _institution.name,
      'affiliation': _affiliation.name,
      'grad_year': _graduationYear.year.toString(),
      'phone_number': _phoneNumber,
      'email_address': _emailAddress
    };
  }
}
