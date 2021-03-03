import 'dart:convert';

/// Processes the new/editted keys of the `mainARB` input (which should
/// be the .arb used to add new keys in the developed app) comparing it
/// with the .arb formatted `oldARBversion` and produces a .arb containing
/// them as the output
String processNewKeys(String mainARB, String oldARBversion) {
  Map<String, dynamic> newARB = json.decode(mainARB),
      oldARB = json.decode(oldARBversion),
      ret = {};

  void addKey(String key) {
    String mainKey, propertiesKey;
    if (key.startsWith('@')) {
      mainKey = key.substring(1);
      propertiesKey = key;
    } else {
      mainKey = key;
      propertiesKey = '@$key';
    }
    ret[mainKey] = newARB[mainKey];
    ret[propertiesKey] = newARB[propertiesKey];
  }

  for (var key in newARB.keys) {
    var value = newARB[key];
    if (!oldARB.keys.contains(key)) {
      addKey(key);
    } else if (value is String) {
      if (value != oldARB[key]) {
        addKey(key);
      }
    }
  }

  return json.encode(ret);
}
