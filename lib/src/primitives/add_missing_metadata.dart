import 'dart:convert';

/// Adds any missing default metadata for keys
///
/// Note that the resulting output is not sorted
String addMissingMetadata(String arbContents) {
  final Map<String, dynamic> contents = json.decode(arbContents);
  final keys = contents.keys.where((key) => !key.startsWith('@')).toList();

  for (final key in keys) {
    if (!contents.containsKey('@$key')) {
      contents['@$key'] = _defaultMetadata;
    }
  }

  final encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(contents);
}

const Map<String, dynamic> _defaultMetadata = {};
