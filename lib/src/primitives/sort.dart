import 'dart:convert';

/// Sorts the .arb formatted String `arbContents` in alphabetically order
/// of the keys, with the @key portion added below it's respective key
String sortARB(String arbContents) {
  final sorted = <String, dynamic>{};
  final Map<String, dynamic> contents = json.decode(arbContents);

  final keys = contents.keys.where((key) => !key.startsWith('@')).toList()
    ..sort();

  // Add at the beginning the [Global Attributes] of the .arb original file, if any
  // [link]: https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification#global-attributes
  contents.keys.where((key) => key.startsWith('@@')).toList()
    ..sort()
    ..forEach((key) {
      sorted[key] = contents[key];
    });
  for (final key in keys) {
    sorted[key] = contents[key];
    if (contents.containsKey('@$key')) {
      sorted['@$key'] = contents['@$key'];
    }
  }

  final encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(sorted);
}
