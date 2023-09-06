import 'dart:convert';

/// Check for duplicated values in arb file string.
/// return Map containing duplicated key-value pairs.
Map<String, dynamic> checkDuplicatesARB(String arbContent) {
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

  final Map<String, dynamic> duplicateMap = {};
  for (final key in arbJsonMap.keys) {
    if (duplicateMap.containsKey(key)) {
      continue;
    }
    final value = arbJsonMap[key];
    final List<String> duplicateValueKeys = arbJsonMap.keys
        .where((k) => k != key)
        .where((k) => arbJsonMap[k] == value)
        .toList();
    if (duplicateValueKeys.isNotEmpty) {
      duplicateMap[key] = value;
      for (final k in duplicateValueKeys) {
        duplicateMap[k] = arbJsonMap[k];
      }
    }
  }

  return duplicateMap;
}
