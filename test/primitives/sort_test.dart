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
  group('common sortings:', () {
    const original = '''{
  "@zKey2": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey11": {
    "description": "simple description"
  }
}''';
    test('default sorting', () {
      const expected = '''{
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original), expected);
    });
    test('case insensitive sorting', () {
      const expected = '''{
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, caseInsensitive: true), expected);
    });
    test('descending sorting', () {
      const expected = '''{
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, descendingOrdering: true), expected);
    });
    test('natural ordering sorting', () {
      const expected = '''{
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, naturalOrdering: true), expected);
    });
    test('descending + case insensitive sorting', () {
      const expected = '''{
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, descendingOrdering: true, caseInsensitive: true), expected);
    });
    test('case insensitive + natural ordering sorting', () {
      const expected = '''{
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, caseInsensitive: true, naturalOrdering: true), expected);
    });
    test('descending + natural ordering sorting', () {
      const expected = '''{
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, descendingOrdering: true, naturalOrdering: true), expected);
    });
    test('case insensitive + natural ordering + descending sorting', () {
      const expected = '''{
  "zKey11": "a simple key",
  "@zKey11": {
    "description": "simple description"
  },
  "zKey2": "a simple key",
  "@zKey2": {
    "description": "simple description"
  },
  "zKey1": "a simple key",
  "@zKey1": {
    "description": "simple description"
  },
  "zKey": "a simple key",
  "@zKey": {
    "description": "simple description"
  },
  "ZKey": "a simple key",
  "@ZKey": {
    "description": "simple description"
  },
  "aKey": "a simple key",
  "@aKey": {
    "description": "simple description"
  }
}''';
      expect(sortARB(original, caseInsensitive: true, naturalOrdering: true, descendingOrdering: true), expected);
    });
  });
}
