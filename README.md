# arb_utils

Common actions to perform over .arb formatted strings

## Usage

A simple usage example:

```dart
import 'package:arb_utils/arb_utils.dart';

main() {
  print('Generating .arb for translators...');
  var chkout = 'latestTranslationsProcessedBranch'; // or a49630b726c or HEAD^3 etc
  Process.runSync('git', 'checkout $chkout'.split(' '));
  var mainARBOld = File('lib/l10n/intl_en.arb').readAsStringSync();
  Process.runSync('git', 'checkout master'.split(' '));
  var mainARBNew = File('lib/l10n/intl_en.arb').readAsStringSync();
  File('lib/l10n/new_translations/intl_en.arb')
      .writeAsStringSync(sortARB(processNewKeys(mainARBNew, mainARBOld)));
  print('lib/l10n/new_translations/intl_en.arb generated');
}
```

## Features

### Manual language switching helpers

Normally there's the need of providing a way of manually changing the locale on runtime. Here is a super easy way of doing so depending on the state manager you use:  
![translation on runtime demo](docs/translations_demo.gif)  
The solution handles the persistance of the user selection for app restarts and so.

#### Provider/BLoC

Given that BLoC relies on Provider for working this solution will work easily for both state managers:

```dart
//make sure this line is written, your IDE may not add it automatically
import 'package:provider/provider.dart';
import 'package:arb_utils/state_managers/l10n_provider.dart';

//prefix your MaterialApp(//... with the following:
ChangeNotifierProvider(
      create: (_) => ProviderL10n(),
      child: Builder(builder: (context) {
        return MaterialApp(
          locale: context.watch<ProviderL10n>().locale,
          supportedLocales: AppLocalizations.supportedLocales,

//now add this widget wherever you want:
import 'package:arb_utils/arb_utils_flutter.dart';

LanguageSelectorDropdown(
  supportedLocales: AppLocalizations.supportedLocales,
  provider: context.read<ProviderL10n>(),
)
```

#### MobX/GetX/GetIt/Riverpod/Binder/Redux/etc

Pull Requests are always welcome :-D!

### ArbClient

A way of getting your ARB translations dynamically, not hardcoded like `S.of(context).key` / `AppLocalizations.of(context).key`. It has been made with the pretension of supporting a way of getting the .arb files from the backend, on demand, but if it suits your use case, it just works. (PR are always welcome)  

```dart
var arbClient = ArbClient(englishArbString, locale: 'en', onMissingKey: (key) => print('ARB key not found: $key'), exceptionOnMissingKey: kDebugMode, onMissingKeyValue: (key) => 'value of $key');
print(arbClient['hellowWorld']); // Hello World!
arbClient.reloadJson(json.decode(spanishArbString));
print(arbClient['hellowWorld']); // ¡Hola Mundo!
print(arbClient.get('helloName',{'name':'Nico'})); // ¡Hola Nico!
```

### Standalone functions

#### sortARB

alters the order of every .arb _key_ alphabetically, putting their _@key_ metadata below every one

```json
{
  "@aKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  },
  "aKey":"a simple key",
}
```

will be converted to:

```json
{
  "aKey":"a simple key",
  "@aKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
}
```

You can also provide a custom sort function.

```dart
var arb1 = '''
{
    "clave":"valor",
    "@clave":{
        "description": "Descripcion"
    },
    "key":"value",
    "@key":{
        "description": "Description"
    }
}''';
var sortedArb1 = sortARB(arb1, (a, b) => a[1].compareTo(b[1]));
print(sortedArb1);
/*
{
    "key":"value",
    "@key":{
        "description": "Description"
    },
    "clave":"valor",
    "@clave":{
        "description": "Descripcion"
    }
}
*/
```

Know that the most common sortings are implemented out of the box with the following parameters

```dart
var sorted = sortARB(arbString, caseInsensitive: false, naturalOrdering: false, descendingOrdering: false);
```

#### diffARBs

Will generate a .arb formatted string with the keys that doesn't appear in both the provided .arb formatted arguments

```dart
var arb1 = '''
{
    "clave":"valor",
    "@clave":{
        "description": "Descripcion"
    },
    "key":"value",
    "@key":{
        "description": "Description"
    }
}''';
var arb2 = '''
{
    "clave":"valor",
    "@clave":{
        "description": "Descripcion"
    },
    "newKey":"new value",
    "@newKey":{
        "description": "new Description"
    }
}''';
var diffed = diffARBs(arb1, arb2);
print(diffed);
/*
{
    "key":"value",
    "@key":{
        "description": "Description"
    },
    "newKey":"new value",
    "@newKey":{
        "description": "new Description"
    }
}
*/
```

#### mergeARBs

Will include the latter .arb keys in the former one and output a .arb formatted string with the merged keys, privileging the latter ones

```dart
var former = '''{
  "aKey":"a simple key",
  "@aKey":{
    "description":"simple description"
  },
  "bKey":"a simple key",
  "@bKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
''';
var latter = '''{
  "aKey":"a MODIFIED simple key",
  "@aKey":{
    "description":"simple description"
  },
  "cKey":"a simple key",
  "@cKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
}''';
var merged = mergeARBs(former,latter);
print(merged);
/*
{
  "aKey":"a MODIFIED simple key",
  "@aKey":{
    "description":"simple description"
  },
  "bKey":"a simple key",
  "@bKey":{
    "description":"simple description"
  },
  "cKey":"a simple key",
  "@cKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
}
*/
```

#### processNewKeys

Compares an .arb formatted string with a previous version of itself and outputs a new .arb formatted string with the new keys found there (also the edited ones)

```dart
var oldVersion = '''{
  "aKey":"a simple key",
  "@aKey":{
    "description":"simple description"
  },
  "bKey":"a simple key",
  "@bKey":{
    "description":"simple description"
  },
  "cKey":"a simple key",
  "@cKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
}''';
var newVersion = '''{
  "aKey":"a MODIFIED simple key",
  "@aKey":{
    "description":"simple description"
  },
  "bKey":"a simple key",
  "@bKey":{
    "description":"simple description"
  },
  "cKey":"a simple key",
  "@cKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"A MORE ROBUST description"
  }
}''';
var newARB = processNewKeys(newVersion, oldVersion);
print(newARB);
/*
{
  "aKey":"a MODIFIED simple key",
  "@aKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"A MORE ROBUST description"
  }
}
*/
```

#### checkDuplicatesARB

Check for duplicated values from arb file string. It returns a Map containing duplicated key-value pairs.

```dart
final arb = '''{
  "aKey":"a simple key",
  "@aKey":{
    "description":"simple description"
  },
  "bKey":"a simple key",
  "@bKey":{
    "description":"simple description"
  },
  "cKey":"a simple key",
  "@cKey":{
    "description":"simple description"
  },
  "zKey":"a simple key",
  "@zKey":{
    "description":"simple description"
  }
}''';
final newARB = checkDuplicatesARB(arb);
print(newARB);
/*
{aKey: a simple key, bKey: a simple key, cKey: a simple key, zKey: a simple key}
*/
```

## Bin scripts

Please run

```sh
dart pub global activate arb_utils
```

to enable `arb_utils` as an executable command on your system.  

##### Sort

To easily sort an arb and update original file, use

```sh
arb_utils sort <INPUT FILE>
```

where `<INPUT FILE>` is a path to the input file.

Also, there are 3 flags for different sorting.

+ --case-insensitive / -i
+ --natural-ordering / -n
+ --descending / -d

For example, to sort with case insensitive and in descending order, use

```sh
arb_utils sort -i -d <INPUT FILE>
```

##### Add Missing Default Metadata

To easily add missing metadata to an arb and update original file, use

```sh
arb_utils generate-meta <INPUT FILE>
```

where `<INPUT FILE>` is a path to the input file.

#### Check

To check the arb files with sub command.

##### Duplicates

To check duplicated values from arb file, use

```sh
arb_utils check duplicates <INPUT FILE>
```

where `<INPUT FILE>` is a path to the input file.

## Reference

Check this article for understanding more about i18n with .arb in Flutter: [https://phrase.com/blog/posts/flutter-localization/](https://phrase.com/blog/posts/flutter-localization/)
