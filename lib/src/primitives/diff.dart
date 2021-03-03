import 'dart:convert';

/// Generates a .arb String with the results of differencing `arb1Contents`
/// with `arb2Contents`: if both the key and it's value are the same
/// that tuple will be omitted of the result.
String diffARBs(String arb1Contents, String arb2Contents) {
  Map<String, dynamic> ret = json.decode(arb1Contents);
  Map<String, dynamic> json2 = json.decode(arb2Contents);
  for (var key in json2.keys) {
    if (ret.containsKey(key)) {
      if (json.encode(ret[key]) == json.encode(json2[key])) {
        ret.remove(key);
      }
    } else {
      ret[key] = json2[key];
    }
  }
  return json.encode(ret);
}
