import 'dart:convert';

/// Includes the novel keys of `arb2Contents` in the `arb1Contents`
/// and returns the result of the merge. In case of discrepances of
/// the values for the same key, the `arb2Contents` will prevail
///
/// In a nutshell `arb1Contents` <-merge-- `arb2Contents`
String mergeARBs(String arb1Contents, String arb2Contents) {
  Map<String, dynamic> ret = json.decode(arb1Contents);
  Map<String, dynamic> json2 = json.decode(arb2Contents);
  for (var key in json2.keys) {
    ret[key] = json2[key];
  }
  return json.encode(ret);
}
