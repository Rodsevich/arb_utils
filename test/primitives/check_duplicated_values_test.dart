import 'package:arb_utils/src/primitives/check_duplicated_values.dart';
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
  const notDuplicatedArb = '''
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

  test('Return Map containing duplicated values when duplicated values found.', () {
    final duplicatedMap = {
      'duplicate1': 'duplicateValue1',
      'duplicate2': 'duplicateValue1',
    };
    expect(checkDuplicatedValuesARB(duplicatedArb), duplicatedMap);
  });

  test('Return empty Map when no duplicated values found.', () {
    expect(checkDuplicatedValuesARB(notDuplicatedArb), {});
  });
}
