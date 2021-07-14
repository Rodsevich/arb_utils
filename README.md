# arb_utils

Common actions to perform over .arb formatted strings

## Usage

A simple usage example:

```dart
import 'package:arb_utils/arb_utils.dart';

main() {
  print('Generating .arb for translators...'); or HEAD^3 etc
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

### Features

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

You could also provide a custom sort function.

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

#### Bin scripts

Please run

```sh
dart pub global activate arb_utils
```

to enable arb_utils to be globally activated.

##### Sort

To easily sort an arb and update original file, use

```sh
pub global run arb_utils:sort <INPUT FILE>
```

where `<INPUT FILE>` is a path to the input file.

Also, there are 3 flags for different sorting.

--case-insensitive / -c
--natural-ordering / -n
--descending / -d

For example, to sort with case insensitive and in descending order, use

```sh
pub global run arb_utils:sort -c -d <INPUT FILE>
```

##### Add Missing Default Metadata

To easily add missing metadata to an arb and update original file, use

```sh
pub global run arb_utils:generate_meta <INPUT FILE>
```

where `<INPUT FILE>` is a path to the input file.
