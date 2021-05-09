import 'package:arb_utils/arb_utils.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

void main() {
  group('sortARB', () {
    test('Given a non-sorted arb, expect correctly sorted', () {
      const arb = '''{
  "@@locale": "en",
  "@@author": "Juan Sorpi",
  "myKey": "Hello world!",
  "@myKey": {
    "description": "The conventional newborn programmer greeting"
  },
  "welcome": "Welcome {firstName}!",
  "@welcome": {
    "description": "A welcome message"
  },
  "numberMessages": "{count, plural, zero{You have no new messages} one{You have 1 new message} other{You have {count} new messages}}",
  "@numberMessages": {
    "description": "An info message about new messages count"
  },
  "whoseBook": "{sex, select, male{His book} female{Her book} other{Their book}}",
  "@whoseBook": {
    "description": "A message determine whose book it is"
  }
}''';

      const expectedValue = '''{
  "@@author": "Juan Sorpi",
  "@@locale": "en",
  "myKey": "Hello world!",
  "@myKey": {
    "description": "The conventional newborn programmer greeting"
  },
  "numberMessages": "{count, plural, zero{You have no new messages} one{You have 1 new message} other{You have {count} new messages}}",
  "@numberMessages": {
    "description": "An info message about new messages count"
  },
  "welcome": "Welcome {firstName}!",
  "@welcome": {
    "description": "A welcome message"
  },
  "whoseBook": "{sex, select, male{His book} female{Her book} other{Their book}}",
  "@whoseBook": {
    "description": "A message determine whose book it is"
  }
}''';

      expect(sortARB(arb), expectedValue);
    });

    test('Given a key without metadata, expect method returns normally', () {
      const arb = '''{
  "@@locale": "en",
  "myKey": "Hello world!"
}''';

      const expectedValue = '''{
  "@@locale": "en",
  "myKey": "Hello world!"
}''';

      expect(() => sortARB(arb), returnsNormally);
      expect(sortARB(arb), expectedValue);
    });
  });
}
