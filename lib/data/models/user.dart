import 'package:tagalong/util/user_data.dart';
import 'package:enum_to_string/enum_to_string.dart';

/// A user model containing pertinent data
class TagAlongUser {
  late String _id;
  late DateTime _createdAt;
  DateTime _updatedAt = DateTime(0);
  late SignInMethod _signInMethod;
  bool _registered = false;
  String _firstName = "";
  String _lastName = "";
  Institution _institution = Institution.invalid;
  Affiliation _affiliation = Affiliation.invalid;
  String _graduationYear = "";
  String _phoneNumber = "";
  String _emailAddress = "";


  /// Initializes an Unregistered User.
  ///
  /// The minimum definition for a valid user requires an ID, a creation date,
  /// and a sign-in method.
  TagAlongUser.unregisteredUser(this._id, this._createdAt, this._signInMethod) {
    _updatedAt = DateTime.now();
    _registered = false;
    _firstName = '';
    _lastName = '';
    _institution = Institution.invalid;
    _affiliation = Affiliation.invalid;
    _graduationYear = '';
    _phoneNumber = '';
    _emailAddress = '';
  }

  /// A named constructor to create a [TagAlongUser] from a Map<String, dynamic>
  TagAlongUser.fromJson(Map<String, dynamic> json) {
    this._id = json['id'];
    this._createdAt = json['created'].toDate();
    this._updatedAt = json['last_updated'].toDate();
    this._signInMethod = EnumToString.fromString(SignInMethod.values, json['sign_in_method'])!;
    this._registered = json['is_registered'];
    this._firstName = json['first_name'];
    this._lastName = json['last_name'];
    this._institution = EnumToString.fromString(Institution.values, json['institution'])!;
    this._affiliation = EnumToString.fromString(Affiliation.values, json['affiliation'])!;
    this._graduationYear = json['grad_year'];
    this._phoneNumber = json['phone_number'];
    this._emailAddress = json['email_address'];
  }

  /// Registers a User.
  ///
  /// Fills in the fields of a User that were left undefined at initialization.
  void registerUser(
      String firstName,
      String lastName,
      Institution institution,
      Affiliation affiliation,
      String graduationYear,
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

  /// Convert a User object to a map that respects its values' types.
  Map<String, dynamic> toMap() {
    // TODO: the key values below should not be hardcoded, figure out a more
    //  central location for them
    return {
      'id': _id,
      'created': _createdAt,
      'last_updated': _updatedAt,
      'sign_in_method': _signInMethod.name,
      'is_registered': _registered,
      'first_name': _firstName,
      'last_name': _lastName,
      'institution': _institution.name,
      'affiliation': _affiliation.name,
      'grad_year': _graduationYear,
      'phone_number': _phoneNumber,
      'email_address': _emailAddress
    };
  }


}
