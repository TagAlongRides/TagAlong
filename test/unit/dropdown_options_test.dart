import 'package:flutter_test/flutter_test.dart';
import 'package:tagalong/widgets/driver_registration/dropdown_options.dart';

void main() {
  test('a saved value missing from the list is kept, first', () {
    expect(withCurrent(['Ford', 'Honda'], 'AMC'), ['AMC', 'Ford', 'Honda']);
  });

  test('a saved value already in the list is not duplicated', () {
    expect(withCurrent(['Ford', 'Honda'], 'Honda'), ['Ford', 'Honda']);
  });

  test('no saved value leaves the list alone', () {
    expect(withCurrent(['Ford'], null), ['Ford']);
    expect(withCurrent(['Ford'], ''), ['Ford']);
  });

  test('an unlisted make keeps its saved model beside Other', () {
    expect(withCurrent(['Other'], 'Matador'), ['Matador', 'Other']);
  });
}
