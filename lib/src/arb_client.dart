import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:intl_utils/src/parser/icu_parser.dart';
import 'package:intl_utils/src/parser/message_format.dart';
import 'package:collection/collection.dart';

typedef MissingKeyDefaultValue = String Function(String key);
typedef MissingKeyCallback = void Function(String key);

/// An object that handles translations dynamically, by processing the .arb JSON on demand.
class ArbClient {
  bool exceptionOnMissingKey;
  late String _arbSource;
  String? locale;
  late Map<String, dynamic> _arbJson;
  MissingKeyCallback onMissingKeyCallback;
  MissingKeyDefaultValue onMissingKeyDefaultValue;
  Map<String, dynamic> _arguments = {};
  //TODO: implement valueListenable
  //bool listenableValues;

  ArbClient(String arbSource,
      {String? locale,
      MissingKeyCallback? onMissingKeyCallback,
      bool? exceptionOnMissingKey,
      MissingKeyDefaultValue? onMissingKeyDefaultValue})
      : this.onMissingKeyCallback = (onMissingKeyCallback ??
            (String key) {
              print('ARB key not found: $key');
            }),
        this.exceptionOnMissingKey = exceptionOnMissingKey ?? false,
        this.onMissingKeyDefaultValue =
            (onMissingKeyDefaultValue ?? (key) => 'value of $key') {
    reloadArb(arbSource, locale: locale);
  }

  /// Gets the arbSource being used by this client.
  String get arbSource => _arbSource;

  void reloadArb(String arbSource, {String? locale}) {
    this._arbSource = arbSource;
    this._arbJson = json.decode(arbSource);
    if (_arbJson.containsKey('@@locale')) {
      this.locale = _arbJson['@@locale'];
    } else if (locale != null) {
      this.locale = locale;
    } else {
      throw ArbClientExceptionNoLocale();
    }
    Intl.defaultLocale = locale;
  }

  /// Returns the value of the given `key`, processed with the given `arguments`, if any.
  /// The arguemtns are a list of values, in the order they appear in the arb value referenced by `key`.
  String get(String key, [Map<String, dynamic> arguments = const {}]) {
    _arguments = arguments;
    if (_arbJson.containsKey(key)) {
      return _processedArbValue(key, _arbJson[key]);
    } else {
      if (exceptionOnMissingKey) {
        throw ArbClientExceptionNoKey(key, arguments);
      } else {
        onMissingKeyCallback(key);
        return onMissingKeyDefaultValue(key);
      }
    }
  }

  /// Syntactic sugar for `get(key, [])`. Intended for being used when no arguments are needed.
  String operator [](String key) => get(key);

  /// Processes the arb `value` and returns the result applied to the current locale.
  String _processedArbValue(String key, String value) {
    String ret;
    try {
      var tryRet =
          IcuParser().parse(value)?.map(_parsedElementToString).join('');
      if (tryRet != null) {
        ret = tryRet;
      } else {
        throw ArbClientExceptionMalformedValue(key, value);
      }
    } on UnimplementedError {
      rethrow;
    } on ArbClientExceptionNoArgument {
      rethrow;
    } catch (e) {
      print('Exception when trying to parse arb value ($value): $e');
      throw ArbClientExceptionMalformedValue(key, value);
    }
    return ret;
  }

  _getArgument(String key) {
    var arg = _arguments[key];
    if (arg == null) {
      throw ArbClientExceptionNoArgument(key, _arbJson[key]);
    }
    return arg;
  }

  String _parsedElementToString(BaseElement element) {
    switch (element.type) {
      case ElementType.literal:
        return element.value;
      case ElementType.plural:
        element as PluralElement;
        List<Option?> options = element.options;
        var zero = options
            .firstWhereOrNull((o) => o!.name == 'zero' || o.name == '=0');
        var one =
            options.firstWhereOrNull((o) => o!.name == 'one' || o.name == '=1');
        var two =
            options.firstWhereOrNull((o) => o!.name == 'two' || o.name == '=2');
        var few = options.firstWhereOrNull((o) => o!.name == 'few');
        var many = options.firstWhereOrNull((o) => o!.name == 'many');
        var other = options.firstWhereOrNull((o) => o!.name == 'other');
        var zeroStr = zero?.value.map(_parsedElementToString).join('') ?? '';
        var oneStr = one?.value.map(_parsedElementToString).join('') ?? '';
        var twoStr = two?.value.map(_parsedElementToString).join('') ?? '';
        var fewStr = few?.value.map(_parsedElementToString).join('') ?? '';
        var manyStr = many?.value.map(_parsedElementToString).join('') ?? '';
        var otherStr = other?.value.map(_parsedElementToString).join('') ?? '';
        return Intl.plural(_getArgument(element.value),
            zero: zeroStr,
            two: twoStr,
            one: oneStr,
            few: fewStr,
            other: otherStr,
            many: manyStr);
      case ElementType.gender:
        element as GenderElement;
        List<Option?> options = element.options;
        var other = options.firstWhereOrNull((o) => o!.name == 'other');
        var male = options.firstWhereOrNull((o) => o!.name == 'male');
        var female = options.firstWhereOrNull((o) => o!.name == 'female');
        var otherStr = other?.value.map(_parsedElementToString).join('') ?? '';
        var maleStr = male?.value.map(_parsedElementToString).join('') ?? '';
        var femaleStr =
            female?.value.map(_parsedElementToString).join('') ?? '';
        return Intl.gender(_getArgument(element.value),
            other: otherStr, female: femaleStr, male: maleStr);
      case ElementType.argument:
        return _getArgument(element.value).toString();
      case ElementType.select:
        throw UnimplementedError('PRs are always welcome! :-D');
    }
  }
}

class ArbClientExceptionNoLocale implements Exception {
  String toString() =>
      'No @@locale key found in the arb source nor locale provided. '
      'The locale is needed for the translation logic, please provide one.';
}

class ArbClientExceptionNoKey implements Exception {
  final String key;
  final Map<String, dynamic> arguments;

  /// Thrown when `key` was searched but not found in the arb file.
  const ArbClientExceptionNoKey(this.key, [this.arguments = const {}]);

  String toString() =>
      'Exception: ARB key not found: $key' +
      (arguments.isNotEmpty ? '($arguments)' : '');
}

class ArbClientExceptionNoArgument implements Exception {
  final String key;
  final String arbValue;

  /// Thrown when `key` requires an argument for being translated but that wasn't provided
  const ArbClientExceptionNoArgument(this.key, this.arbValue);

  String toString() => 'Exception: ARB argument not provided: $key ($arbValue)';
}

class ArbClientExceptionMalformedValue implements Exception {
  final String key;
  final String value;

  /// Thrown when `key` references an ARB value that is not ICU-compliant
  const ArbClientExceptionMalformedValue(this.key, this.value);

  String toString() =>
      "ArbClientException: ARB key '$key' points to a malformed value: $value";
}
