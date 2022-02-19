import 'dart:convert';

import 'package:arb_utils/src/arb_client.dart';
import 'package:test/test.dart';

var englishArb = '''{
  "nMails": "{count,plural, =0{You have no mails, {name}} =1{{name}! You have one mail!} =2{You have two mails, {name}} few{You have {count} mails, {name}} many{You have several ({count}) mails, {name}} other{You have like {count} mails, {name}}}",
  "@nMails": {
    "description": "A plural message that informs the user the amount of mails he has to read",
    "placeholders": {
      "count": {},
      "name": {
        "example": "Nico"
      }
    }
  },
  "new_test_key": "A new test key",
  "@new_test_key": {
    "description": "Key added just for testing purposes"
  },
  "pageHomeBirthday": "{sex, select, male{His birthday} female{Her birthday} other{The birthday of them}}",
  "@pageHomeBirthday": {
    "description": "Sex testing key",
    "placeholders": {
      "sex": {}
    }
  }
}''';
var spanishArb = '''{
  "nMails": "{count,plural, =0{No tenés mails, {name}} =1{¡{name}! ¡Tenés un mail!} =2{Tenés 2 mails, {name}} few{Tenés {count} mails, {name}} many{Tenés muchos ({count}) mails, {name}} other{Tenés como {count} mails, {name}}}",
  "@nMails": {
    "description": "A plural message that informs the user the amount of mails he has to read",
    "placeholders": {
      "count": {},
      "name": {
        "example": "Nico"
      }
    }
  },
  "new_test_key": "Una nueva clave de prueba",
  "@new_test_key": {
    "description": "Key added just for testing purposes"
  },
  "pageHomeBirthday": "{sex, select, male{Cumple, de él} female{Cumple, de ella} other{Quién carajo usará esto, ¿no?}}",
  "@pageHomeBirthday": {
    "description": "Sex testing key",
    "placeholders": {
      "sex": {}
    }
  }
}''';

main() {
  group('english straightforward working well', () {
    var client = ArbClient(json.decode(englishArb));
    test('retrieves the single key with syntactic sugar []', () {
      expect(client['new_test_key'], equals('A new test key'));
    });
    test('retrieves the single key with get', () {
      expect(client.get('new_test_key'), equals('A new test key'));
    });
    test('retrieves the correct translation with plurals', () {
      // "nMails": "{count,plural, =0{You have no mails, {name}}
      //=1{{name}! You have one mail!}
      //=2{You have two mails, {name}}
      //few{You have {count} mails, {name}}
      //many{You have several ({count}) mails, {name}}
      //other{You have like {count} mails, {name}}}",
      expect(client.get('nMails', {'count': 0, 'name': 'Nico'}),
          equals('You have no mails, Nico'));
      expect(client.get('nMails', {'count': 1, 'name': 'Nico'}),
          equals('Nico! You have one mail!'));
      expect(client.get('nMails', {'count': 2, 'name': 'Nico'}),
          equals('You have two mails, Nico'));
      // with English the logic only checks for 0, 1, 2 and other:
      expect(client.get('nMails', {'count': 4, 'name': 'Nico'}),
          equals('You have like 4 mails, Nico'));
      expect(client.get('nMails', {'count': 13, 'name': 'Nico'}),
          equals('You have like 13 mails, Nico'));
      expect(client.get('nMails', {'count': 3456, 'name': 'Nico'}),
          equals('You have like 3456 mails, Nico'));
    });
    test('retrieves the correct translation with genders', () {
      expect(client.get('pageHomeBirthday', {'sex': 'male'}),
          equals('His birthday'));
      expect(client.get('pageHomeBirthday', {'sex': 'female'}),
          equals('Her birthday'));
      expect(client.get('pageHomeBirthday', {'sex': 'anything'}),
          equals('The birthday of them'));
      expect(client.get('pageHomeBirthday', {'sex': 'anything else'}),
          equals('The birthday of them'));
      expect(client.get('pageHomeBirthday', {'sex': 'other'}),
          equals('The birthday of them'));
    });
  });
  group('Faulty behaviour working well', () {
    ArbClient client;
    test('Respects exceptionOnMissingKey configuration when missing keys', () {
      client = ArbClient(json.decode(englishArb), exceptionOnMissingKey: true);
      expect(() => client.get('inexistent_key'),
          throwsA(isA<ArbClientExceptionNoKey>()));
      client = ArbClient(json.decode(englishArb), exceptionOnMissingKey: false);
      expect(client.get('inexistent_key'), equals('value of inexistent_key'));
    });
    test('Follows the onMissingKeyDefaultValue: configuration', () {
      client = ArbClient(json.decode(englishArb),
          onMissingKeyDefaultValue: (k) => 'missing key: $k');
      expect(
          client.get('inexistent_key'), equals('missing key: inexistent_key'));
      client = ArbClient(json.decode(englishArb),
          onMissingKeyDefaultValue: (k) => 'key: $k');
      expect(client.get('inexistent_key'), equals('key: inexistent_key'));
    });
    test('calls the callback function when key is missing', () {
      var callback = expectAsync1((key) => print(key), count: 2);
      client =
          ArbClient(json.decode(englishArb), onMissingKeyCallback: callback);
      client.get('inexistent_key');
      client.get('new_test_key');
      client.get('inexistent_key');
    });
  });
}
