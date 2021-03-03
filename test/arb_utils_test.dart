import 'package:arb_utils/arb_utils.dart';
import 'package:test/test.dart';

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
void main() {
  group('ARB Utils', () {
    test('Merge', () {
      var merged = mergeARBs(arb1, arb2);
      print(merged);
      expect('clave'.allMatches(merged).length, equals(2));
      expect('key'.allMatches(merged).length, equals(2));
      expect('newKey'.allMatches(merged).length, equals(2));
    });
    test('Diff', () {
      var diffed = diffARBs(arb1, arb2);
      print(diffed);
      expect('key'.allMatches(diffed).length, equals(2));
      expect('newKey'.allMatches(diffed).length, equals(2));
      expect(diffed, isNot(contains('clave')));
    });
  });
}
