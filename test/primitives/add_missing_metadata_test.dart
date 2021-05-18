import 'package:arb_utils/src/primitives/add_missing_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('addMissingMetadata', () {
    test('Given an arb where some keys have no metadata, expect metadata added', () {
      const arb = '''{
  "@@locale": "en",
  "myKey": "Hello world!",
  "welcome": "Welcome {firstName}!",
  "@welcome": {
    "description": "A welcome message"
  }
}''';

      const expectedValue = '''{
  "@@locale": "en",
  "myKey": "Hello world!",
  "welcome": "Welcome {firstName}!",
  "@welcome": {
    "description": "A welcome message"
  },
  "@myKey": {}
}''';

      expect(addMissingMetadata(arb), expectedValue);
    });

    test('Given an arb where all keys have metadata, expect no changes', () {
      const arb = '''{
  "@@locale": "en",
  "myKey": "Hello world!",
  "@myKey": {
    "description": "The conventional newborn programmer greeting"
  },
  "welcome": "Welcome {firstName}!",
  "@welcome": {
    "description": "A welcome message"
  }
}''';

      expect(addMissingMetadata(arb), arb);
    });

    test('Given a non-valid arb, expect exception raised', () {
      const arb = '''{
  "@@locale": "en",
  "myKey": "Hello world!",
}''';

      expect(
        () => addMissingMetadata(arb),
        throwsFormatException,
      );
    });
  });
}
