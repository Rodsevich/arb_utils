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
  },
  "trafficLight": "{light, select, red{stop} yellow{ready to go} green{go} other{-}}",
  "@trafficLight": {
    "description": "Select testing key",
    "placeholders": {
      "light": {}
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
    var client = ArbClient(englishArb, locale: 'en');
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
    test('retrieves the correct translation with select', () {
      expect(client.get('trafficLight', {'light': 'red'}),
          equals('stop'));
      expect(client.get('trafficLight', {'light': 'yellow'}),
          equals('ready to go'));
      expect(client.get('trafficLight', {'light': 'green'}),
          equals('go'));
      expect(client.get('trafficLight', {'light': 'ngangong'}),
          equals('-'));
    });
  });

  group('english - spanish translations change working well', () {
    test('works with simple values', () {
      var client = ArbClient(englishArb, locale: 'en');
      expect(client['new_test_key'], equals('A new test key'));
      client.reloadArb(spanishArb, locale: 'es');
      expect(client['new_test_key'], equals('Una nueva clave de prueba'));
    });
    test('works with plurals', () {
      var client = ArbClient(englishArb, locale: 'en');
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
      client.reloadArb(spanishArb, locale: 'es');
      // "nMails": "{count,plural, =0{No tenés mails, {name}}
      //=1{¡{name}! ¡Tenés un mail!}
      //=2{Tenés 2 mails, {name}}
      //few{Tenés {count} mails, {name}}
      //many{Tenés muchos ({count}) mails, {name}}
      //other{Tenés como {count} mails, {name}}}",
      expect(client.get('nMails', {'count': 0, 'name': 'Nico'}),
          equals('No tenés mails, Nico'));
      expect(client.get('nMails', {'count': 1, 'name': 'Nico'}),
          equals('¡Nico! ¡Tenés un mail!'));
      expect(client.get('nMails', {'count': 2, 'name': 'Nico'}),
          equals('Tenés 2 mails, Nico'));
      // with Spanish the logic only checks for 0, 1, 2 and other:
      expect(client.get('nMails', {'count': 4, 'name': 'Nico'}),
          equals('Tenés como 4 mails, Nico'));
      expect(client.get('nMails', {'count': 13, 'name': 'Nico'}),
          equals('Tenés como 13 mails, Nico'));
      expect(client.get('nMails', {'count': 3456, 'name': 'Nico'}),
          equals('Tenés como 3456 mails, Nico'));
      //use Polish for checking the plural rules:
      // _i = integer part of the number
      // _v = number of visible fraction numbers
      // if (_i == 1 && _v == 0) {
      //   return ONE;
      // }
      // if (_v == 0 &&
      //     _i % 10 >= 2 &&
      //     _i % 10 <= 4 &&
      //     (_i % 100 < 12 || _i % 100 > 14)) {
      //   return FEW;
      // }
      // if (_v == 0 && _i != 1 && _i % 10 >= 0 && _i % 10 <= 1 ||
      //     _v == 0 && _i % 10 >= 5 && _i % 10 <= 9 ||
      //     _v == 0 && _i % 100 >= 12 && _i % 100 <= 14) {
      //   return MANY;
      // }
      // return OTHER;
      client.reloadArb(spanishArb, locale: 'pl');
      // with Polish the logic is as above (go yourself to decrypt that!)
      //few{Tenés {count} mails, {name}}
      //many{Tenés muchos ({count}) mails, {name}}
      expect(client.get('nMails', {'count': 3, 'name': 'Nico'}),
          equals('Tenés 3 mails, Nico')); //few
      expect(client.get('nMails', {'count': 103, 'name': 'Nico'}),
          equals('Tenés 103 mails, Nico')); //few
      expect(client.get('nMails', {'count': 9, 'name': 'Nico'}),
          equals('Tenés muchos (9) mails, Nico')); //many
      expect(client.get('nMails', {'count': 3456.12, 'name': 'Nico'}),
          equals('Tenés como 3456.12 mails, Nico')); //other
    });
  });
  group('Faulty behaviour working well', () {
    ArbClient client;
    test('Respects exceptionOnMissingKey configuration when missing keys', () {
      client = ArbClient(englishArb, locale: 'en', exceptionOnMissingKey: true);
      expect(() => client.get('inexistent_key'),
          throwsA(isA<ArbClientExceptionNoKey>()));
      client =
          ArbClient(englishArb, locale: 'en', exceptionOnMissingKey: false);
      expect(client.get('inexistent_key'), equals('value of inexistent_key'));
    });
    test('Follows the onMissingKeyDefaultValue: configuration', () {
      client = ArbClient(englishArb,
          locale: 'en', onMissingKeyDefaultValue: (k) => 'missing key: $k');
      expect(
          client.get('inexistent_key'), equals('missing key: inexistent_key'));
      client = ArbClient(englishArb,
          locale: 'en', onMissingKeyDefaultValue: (k) => 'key: $k');
      expect(client.get('inexistent_key'), equals('key: inexistent_key'));
    });
    test('calls the callback function when key is missing', () {
      var callback = expectAsync1((key) => print(key), count: 2);
      client =
          ArbClient(englishArb, locale: 'en', onMissingKeyCallback: callback);
      client.get('inexistent_key');
      client.get('new_test_key');
      client.get('inexistent_key');
    });
    test('fails when no locale is provided', () {
      expect(() => client = ArbClient(englishArb),
          throwsA(isA<ArbClientExceptionNoLocale>()));
      expect(ArbClient(englishArb, locale: 'en'), isA<ArbClient>());
      expect(ArbClient('{"@@locale":"en",${englishArb.substring(1)}'),
          isA<ArbClient>());
    });
  });
}
