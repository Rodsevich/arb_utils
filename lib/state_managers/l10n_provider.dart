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

  /// Gets or sets the current application locale.
  ///
  /// If `locale` is `null`, the locale preference is removed and the app
  /// falls back to the system language.
  ///
  /// Note: The locale is persisted asynchronously in SharedPreferences.
  Locale? get locale => _locale;
  set locale(Locale? locale) {
    SharedPreferences.getInstance().then((preferences) {
      if (locale == null) {
        preferences.remove('locale');
      } else {
        preferences.setString('locale', locale.toString());
      }
      _locale = locale;
      notifyListeners();
    });
  }
}
