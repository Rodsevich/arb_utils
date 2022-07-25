import 'package:arb_utils/src/utils/locale.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A solution for storing the locale changes in the application's
/// SharedPreferences as well as using it for changing the language
/// of the application.
class ProviderL10n extends ChangeNotifier {
  Locale? _locale;
  ProviderL10n({
    Locale? defaultLocale,
  }) {
    SharedPreferences.getInstance().then((preferences) {
      var storedLocale = preferences.getString('locale');
      if (storedLocale != null) {
        _locale = getLocaleFromTag(storedLocale);
        notifyListeners();
      }
    });
  }

  Locale? get locale => _locale;
  set locale(Locale? locale) {
    SharedPreferences.getInstance().then((preferences) {
      preferences.setString('locale', locale.toString());
      _locale = locale;
      notifyListeners();
    });
  }
}
