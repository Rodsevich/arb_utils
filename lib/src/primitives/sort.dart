import 'dart:convert';

/// Sorts the .arb formatted String `arbContents` in alphabetically order
/// of the keys, with the @key portion added below it's respective key
String sortARB(String arbContents) {
  Map<String, dynamic> ret = {}, contents = json.decode(arbContents);
  var list = contents.keys.where((key) => !key.startsWith('@')).toList();
  list.sort();
  for (var key in list) {
    ret[key] = contents[key];
    ret['@$key'] = contents['@$key'];
  }
  return json.encode(ret);
}
