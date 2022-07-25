import 'package:arb_utils/src/configs/constants.dart';
import 'package:arb_utils/src/utils/locale.dart';
import 'package:arb_utils/state_managers/l10n_provider.dart';
import 'package:flutter/material.dart';

/// The strategy for displaying the languages names
enum LanguagesDisplayLanguage {
  /// Display the language name in the self language.
  native,

  /// Display the language name in English.
  english,

  // ToDo: to be supported
  // /// Display the language name using the language tag from the translations
  // /// of the current locale. If it doesn't exists the original approach is
  // /// used for that particular language. E.g.:
  // /// es_AR -<es>-> castellano argentino
  // /// es_AR -<en>-> argentine Spanish
  // translated,
}

typedef LanguageChangeHandler = Function(Locale chosenLocale);

/// A [DropdownButton] prepared for displaying the supported languages. Use with `AppLocalizations.supportedLocales`
class LanguageSelectorDropdown extends StatelessWidget {
  LanguageSelectorDropdown({
    Key? key,

    /// Provided the [AppLocalizations.supportedLocales]
    required this.supportedLocales,

    /// A callback to be called when the user selects a language.
    this.languageChangeHandler,

    /// If provided it will be used, else a [Icons.translate] will be used instead.
    this.icon,
    this.languagesDisplayLanguage = LanguagesDisplayLanguage.native,

    /// If a [ProviderL10n] is provided, the locale of it will be changed according to the language chosen
    this.provider,
  }) : super(key: key) {
    var supportedLocalesTags = supportedLocales.map((e) => e.toLanguageTag());
    final Map<String, Map<String, String>> localesListUnsorted = {};
    languagesNames.keys
        .where((e) => supportedLocalesTags.contains(e))
        .forEach((supportedLanguageKey) {
      localesList[supportedLanguageKey] = languagesNames[supportedLanguageKey]!;
    });
    localesListUnsorted.keys.toList()
      ..sort()
      ..forEach((key) {
        localesList[key] = localesListUnsorted[key]!;
      });
  }

  final ProviderL10n? provider;
  final List<Locale> supportedLocales;
  final Map<String, Map<String, String>> localesList = {};
  final Icon? icon;
  final LanguagesDisplayLanguage languagesDisplayLanguage;
  final LanguageChangeHandler? languageChangeHandler;

  String getLanguageName(String localeId, Map<String, String> language) {
    String? ret;
    switch (languagesDisplayLanguage) {
      case LanguagesDisplayLanguage.native:
        ret = language['nativeName'];
        break;
      case LanguagesDisplayLanguage.english:
        ret = language['englishName'];
        break;
      //ToDo: to be supported
      // case LanguagesDisplayLanguage.translated:
      //   ret = language[Constants.languageTranslatedName];
      //   break;
      default:
        throw UnsupportedError(
            'This language display strategy is not supported');
    }
    if (ret == null) {
      throw UnsupportedError(
          'The language $localeId has no translation. Please make a PR or report it.');
    }
    return ret;
  }

  void languageChangedHandler(String? localeId) {
    if (localeId == null) {
      return;
    }
    var locale = getLocaleFromTag(localeId);
    if (languageChangeHandler != null) {
      languageChangeHandler!(locale);
    }
    provider?.locale = locale;
  }

  DropdownMenuItem<String> _buildMenuItem(
      MapEntry<String, Map<String, String>> language) {
    return DropdownMenuItem<String>(
      child: Text(
        getLanguageName(language.key, language.value),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: language.key,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      icon: icon ?? Icon(Icons.translate),
      items: localesList.entries.map(_buildMenuItem).toList(),
      onChanged: languageChangedHandler,
    );
  }
}
