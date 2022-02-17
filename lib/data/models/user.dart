import 'package:tagalong/util/user_data.dart';

/// A user model containing pertinent data
class TagAlongUser {
  late String _id;
  late DateTime _createdAt;
  DateTime _updatedAt = DateTime(0);
  String _institution = Institution.INVALID;
  String _firstName = "";
  String _lastName = "";
  String _graduationYear = "";
  String _phoneNumber = "";
  String _emailAddress = "";
  Driver? _driverData;
  bool _verified = false;
  bool _registered = false;
  late String _signInMethod;


  String get email => _emailAddress;


  /// Initializes an Unregistered User.
  ///
  /// The minimum definition for a valid user requires an ID, a creation date,
  /// and a sign-in method. This is used when a user successfully logs in with
  /// Facebook, but never completes user registration.
  TagAlongUser.unregisteredUser({
    required String id,
    required DateTime createdAt,
    required String signinMethod}) {
      _id = id;
      _createdAt = createdAt;
      _updatedAt = DateTime.now();
      _institution = Institution.INVALID;
      _firstName = '';
      _lastName = '';
      _graduationYear = '';
      _phoneNumber = '';
      _emailAddress = '';
      _driverData = null;
      _verified = false;
      _registered = false;
  }

  /// A named constructor to create a [TagAlongUser] from a Map<String, dynamic>
  TagAlongUser.fromJson(Map<String, dynamic> json):
    this._id = json['id'],
    this._createdAt = json['created'].toDate(),
    this._updatedAt = json['last_updated'].toDate(),
    this._registered = json['is_registered'],
    this._firstName = json['first_name'],
    this._lastName = json['last_name'],
    this._signInMethod = json['sign_in_method'],
    this._institution = json['institution'],
    this._graduationYear = json['grad_year'],
    this._phoneNumber = json['phone_number'],
    this._emailAddress = json['email_address'];


  /// Registers a User.
  ///
  /// Fills in the fields of a User that were left undefined at initialization.
  void registerUser(
      String firstName,
      String lastName,
      String institution,
      String graduationYear,
      String phoneNumber,
      String emailAddress) {
    _firstName = firstName;
    _lastName = lastName;
    _institution = institution;
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

  /// Convert a User object to a map that respects its values' types.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'created': _createdAt,
      'last_updated': _updatedAt,
      'sign_in_method': _signInMethod,
      'is_registered': _registered,
      'first_name': _firstName,
      'last_name': _lastName,
      'institution': _institution,
      'grad_year': _graduationYear,
      'phone_number': _phoneNumber,
      'email_address': _emailAddress
    };
  }


}
