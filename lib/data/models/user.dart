import 'package:tagalong/data/models/driver.dart';
import 'package:tagalong/util/user_data.dart';

/// A user model containing pertinent data
class TagAlongUser {
  late String _id;
  late DateTime _createdAt;
  DateTime _updatedAt = DateTime(0);
  String _institution = Institution.INVALID;
  String _firstName = "";
  String _lastName = "";
  String? _graduationYear;
  String _phoneNumber = "";
  String _emailAddress = "";
  Driver? driverData;
  bool _registered = false;
  late String _signInMethod;


  String get email => _emailAddress;

  /// Flag indicating whether a user is registered or not.
  bool isRegistered() {
    return _registered;
  }

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
      _graduationYear = null;
      _phoneNumber = '';
      _emailAddress = '';
      driverData = null;
      _registered = false;
      _signInMethod = signinMethod;
  }

  /// A named constructor to create a [TagAlongUser] from a Map<String, dynamic>
  TagAlongUser.fromJson(Map<String, dynamic> json):
    this._id = json['id'],
    this._createdAt = json['created'].toDate(),
    this._updatedAt = json['last_updated'].toDate(),
    this._institution = json['institution'],
    this._firstName = json['first_name'],
    this._lastName = json['last_name'],
    this._signInMethod = json['sign_in_method'],
    this._graduationYear = json['grad_year'],
    this._registered = json['is_registered'],
    this._phoneNumber = json['phone_number'],
    this._emailAddress = json['email_address'] {
    if (json['driver_data'] == Map) {
      driverData = Driver.fromJson(json['driver_data']);
    }
  }

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
    driverData = null;

    // TODO: Probably don't want to rely on system time like this...
    _updatedAt = DateTime.now();
  }

  /// Convert a User object to a map that respects its values' types.
  Map<String, dynamic> toJson() {
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
      'email_address': _emailAddress,
      'driver_data': driverData?.toJson()
    };
  }

  /// Updates this instance's [TagAlongUser] in-memory only
  void updateTagAlongUser(Map<String, dynamic> data) {
    _id = data['id'] ?? _id;
    _createdAt = data['created']?.toDate() ?? _createdAt;
    _updatedAt = data['last_updated']?.toDate() ?? _updatedAt;
    _signInMethod = data['sign_in_method'] ?? _signInMethod;
    _registered = data['is_registered'] ?? _registered;
    _firstName = data['first_name'] ?? _firstName;
    _lastName = data['last_name'] ?? _lastName;
    _institution = data['institution'] ?? _institution;
    _graduationYear = data['grad_year'] ?? _graduationYear;
    _phoneNumber = data['phone_number'] ?? _phoneNumber;
    _emailAddress = data['email_address'] ?? _emailAddress;
    driverData = data['driver_data'] ?? driverData;
  }

}
