extension StringExtension on String {
  String changeCurrencyHtmlCode() {
    if (contains('&euro;')) return replaceAll('&euro;', '\u{20AC}');
    return this;
  }

  _toProperCase() {
    if (this == null) {
      return null;
    }
    if (length == 1) {
      return toUpperCase();
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  toTitleCase() {
    return replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str._toProperCase()).join(' ');
  }
}
