extension StringExtension on String {
  String changeCurrencyHtmlCode() {
    if (contains('&euro;')) return replaceAll('&euro;', '\u{20AC}');
    return this;
  }
}
