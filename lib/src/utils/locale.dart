import 'package:flutter/material.dart';

/// Transforms a [String] like 'es_AR' to a [Locale] with language code
/// 'es' and country code 'AR'.
Locale getLocaleFromTag(String localeTag) {
  var languageParts = RegExp(r'([a-z]*)[_-]?([a-z]*)').firstMatch(localeTag);
  var languageCode = languageParts?.group(1);
  var countryCode = languageParts?.group(2);
  if (languageCode == null) {
    throw StateError("Can't parse locale tag '$localeTag'");
  }
  return Locale(languageCode, countryCode);
}
