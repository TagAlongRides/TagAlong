enum SignInMethod {
  invalid,
  facebook,
}

extension SignInMethodExtension on SignInMethod {
  static const names = {
    SignInMethod.invalid: 'invalid',
    SignInMethod.facebook: 'facebook',
  };

  String? get name => names[this];
}

enum Institution {
  invalid,
  virginiaTech,
}

extension InstitutionExtension on Institution {
  static const names = {
    Institution.invalid: 'invalid',
    Institution.virginiaTech: 'virginia_tech',
  };

  String? get name => names[this];
}

enum Affiliation {
  invalid,
  undergraduateStudent,
  graduateStudent,
  postDoc,
  facultyStaff,
  other
}

extension AffiliationExtension on Affiliation {
  static const names = {
    Affiliation.invalid: 'invalid',
    Affiliation.undergraduateStudent: 'student_undergrad',
    Affiliation.graduateStudent: 'student_grad',
    Affiliation.postDoc: 'post_doc',
    Affiliation.facultyStaff: 'faculty_staff',
    Affiliation.other: 'other',
  };

  String? get name => names[this];
}
