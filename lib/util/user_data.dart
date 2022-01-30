class SignInMethod {
  static const String INVALID = 'Invalid';
  static const String FACEBOOK = 'Facebook';

  static List<String> values = [INVALID, FACEBOOK];
}

class Institution {
  static const String INVALID = 'Invalid';
  static const String VIRGINIA_TECH = 'Virginia Tech';

  static List<String> values = [INVALID, VIRGINIA_TECH];
}

class Affiliation {
  static const String INVALID = 'Invalid';
  static const String UNGRADUATE_STUDENT = 'Undergraduate Student';
  static const String GRADUATE_STUDENT = 'Graduate Student';
  static const String POST_DOC = 'Post-Doc';
  static const String FACULTY_STAFF = 'Faculty Staff';
  static const String OTHER = 'Other';

  static List<String> values = [
    INVALID,
    UNGRADUATE_STUDENT,
    GRADUATE_STUDENT,
    POST_DOC,
    FACULTY_STAFF,
    OTHER
  ];
}


// TODO: Refactor for Car and Institution APIs?
// enum SignInMethod {
//   invalid,
//   facebook,
// }
//
// extension SignInMethodExtension on SignInMethod {
//   static BiMap names = BiMap();
//   names.addAll(
//       {
//         SignInMethod.invalid: 'Invalid',
//         SignInMethod.facebook: 'Facebook',
//       }
//       );
//
//
//   String? get name => names[this];
//
//   static List<String> getNames() {
//     return names.values.toList();
//   }
// }
//
// enum Institution {
//   invalid,
//   virginiaTech,
// }
//
// extension InstitutionExtension on Institution {
//   static const names = {
//     Institution.invalid: 'Invalid',
//     Institution.virginiaTech: 'Virginia Tech',
//   };
//
//   String? get name => names[this];
//
//   static List<String> getNames() {
//     return names.values.toList().sublist(1);
//   }
// }
//
// enum Affiliation {
//   invalid,
//   undergraduateStudent,
//   graduateStudent,
//   postDoc,
//   facultyStaff,
//   other
// }
//
// extension AffiliationExtension on Affiliation {
//   static const names = {
//     Affiliation.invalid: 'Invalid',
//     Affiliation.undergraduateStudent: 'Undergraduate Student',
//     Affiliation.graduateStudent: 'Graduate Student',
//     Affiliation.postDoc: 'Post-Doc',
//     Affiliation.facultyStaff: 'Faculty Staff',
//     Affiliation.other: 'Other',
//   };
//
//   String? get name => names[this];
//
//   static List<String> getNames() {
//     return names.values.toList().sublist(1);
//   }
// }
