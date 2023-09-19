import 'dart:convert';

/// Check for duplicated values in arb file string.
/// Return a Map containing duplicated key-value pairs.
Map<String, dynamic> checkDuplicatedValuesARB(String arbContent) {
  final Map<String, dynamic> arbJsonMap = json.decode(arbContent);
  arbJsonMap.removeWhere((key, value) => key.startsWith('@@'));
  arbJsonMap.removeWhere((key, value) => key.startsWith('@'));
  arbJsonMap.removeWhere((key, value) {
    if (value is String) {
      return RegExp(r'.*\{.*\}.*').hasMatch(value);
    } else {
      return false;
    }
  });

  final Map<String, dynamic> duplicatedValuesMap = {};
  for (final key in arbJsonMap.keys) {
    if (duplicatedValuesMap.containsKey(key)) {
      continue;
    }
    final value = arbJsonMap[key];
    final List<String> duplicateValueKeys = arbJsonMap.keys
        .where((k) => k != key)
        .where((k) => arbJsonMap[k] == value)
        .toList();
    if (duplicateValueKeys.isNotEmpty) {
      duplicatedValuesMap[key] = value;
      for (final k in duplicateValueKeys) {
        duplicatedValuesMap[k] = arbJsonMap[k];
      }
    }
  }

  return duplicatedValuesMap;
}
