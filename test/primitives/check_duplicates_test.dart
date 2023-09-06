import 'package:arb_utils/src/primitives/check_duplicates.dart';
import 'package:test/test.dart';

void main() {
  const duplicatedArb = '''
  {
    "@@name": "en",
    "@@url": "http://www.example.com/en",
    "@@language": "en",
    "noDuplicate1": "noDuplicateValue1",
    "noDuplicate2": "noDuplicateValue2",
    "duplicate1": "duplicateValue1",
    "duplicate2": "duplicateValue1",
    "duplicatePlaceholder1": "{value}",
    "@duplicatePlaceholder1": {
      "placeholders": {
        "value": {
          "type": "int"
        }
      }
    },
    "duplicatePlaceholder2": "{value}",
    "@duplicatePlaceholder2": {
      "placeholders": {
        "value": {
          "type": "int"
        }
      }
    }
  }
  ''';
  const noDuplicatedArb = '''
  {
    "@@name": "en",
    "@@url": "http://www.example.com/en",
    "@@language": "en",
    "noDuplicate1": "noDuplicate1",
    "noDuplicate2": "noDuplicate2",
    "duplicatePlaceholder1": "{value}",
    "@duplicatePlaceholder1": {
      "placeholders": {
        "value": {
          "type": "int"
        }
      }
    },
    "duplicatePlaceholder2": "{value}",
    "@duplicatePlaceholder2": {
      "placeholders": {
        "value": {
          "type": "int"
        }
      }
    }
  }
  ''';

  test('Return duplicated map when duplicated value found.', () {
    final duplicatedMap = {
      'duplicate1': 'duplicateValue1',
      'duplicate2': 'duplicateValue1',
    };
    expect(checkDuplicatesARB(duplicatedArb), duplicatedMap);
  });

  test('Return empty map when no duplicated value found.', () {
    expect(checkDuplicatesARB(noDuplicatedArb), {});
  });
}
