import 'package:flutter_test/flutter_test.dart';
import 'package:tagalong/data/models/user.dart';
import 'package:tagalong/util/user_data.dart';

void main() {
  test('Initialization does not mark as registered', () {
    final user = TagAlongUser("ABC123", DateTime.now(), SignInMethod.facebook);
    expect(user.isRegistered(), false);
  });

  test('Registering does mark as registered', () {
    final user = TagAlongUser("ABC123", DateTime.now(), SignInMethod.facebook);
    user.registerUser("John", "Doe", Institution.virginiaTech,
        Affiliation.other, DateTime(2024), "1112223333", "johndoe@email.com");
    expect(user.isRegistered(), true);
  });

  test('toMap returns expected values', () {
    final user = TagAlongUser("ABC123", DateTime.now(), SignInMethod.facebook);
    user.registerUser("John", "Doe", Institution.virginiaTech,
        Affiliation.other, DateTime(2024), "1112223333", "johndoe@email.com");

    final Map<String, String?> userMap = user.toMap();
    // TODO: Figure out a way to check values of creation and update times
    expect(userMap["id"], "ABC123");
    expect(userMap["sign_in_method"], "facebook");
    expect(userMap["is_registered"], "true");
    expect(userMap["first_name"], "John");
    expect(userMap["last_name"], "Doe");
    expect(userMap["institution"], "virginia_tech");
    expect(userMap["affiliation"], "other");
    expect(userMap["grad_year"], "2024");
    expect(userMap["phone_number"], "1112223333");
    expect(userMap["email_address"], "johndoe@email.com");
  });

  // TODO: Figure out how to test the user_data utils in an automated way
  //  i.e. if a new value is added to enum, check that the name extension
  //  supports it automatically
}
