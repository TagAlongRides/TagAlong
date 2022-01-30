enum SignInMethod {
  invalid,
  facebook,
}

extension SignInMethodExtension on SignInMethod {
  static const names = {
    SignInMethod.invalid: 'Invalid',
    SignInMethod.facebook: 'Facebook',
  };

  String? get name => names[this];

  static List<String> getNames() {
    return names.values.toList();
  }
}

enum Institution {
  invalid,
  virginiaTech,
}

extension InstitutionExtension on Institution {
  static const names = {
    Institution.invalid: 'Invalid',
    Institution.virginiaTech: 'Virginia Tech',
  };

  String? get name => names[this];

  static List<String> getNames() {
    return names.values.toList().sublist(1);
  }
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
    Affiliation.invalid: 'Invalid',
    Affiliation.undergraduateStudent: 'Undergraduate Student',
    Affiliation.graduateStudent: 'Graduate Student',
    Affiliation.postDoc: 'Post-Doc',
    Affiliation.facultyStaff: 'Faculty Staff',
    Affiliation.other: 'Other',
  };

  String? get name => names[this];

  static List<String> getNames() {
    return names.values.toList().sublist(1);
  }
}
