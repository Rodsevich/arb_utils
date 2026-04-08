import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for the CLI ', () {
    const sampleArbFile = 'test/samples/unsorted.arb';
    var initialContents = '';
    var finalContents = '';
    var output = <String>[];

    void runCommand(List<String> args) {
      initialContents = File(sampleArbFile).readAsStringSync().trim();

      final result = Process.runSync('dart', args);
      output = result.stdout.toString().split('\n');
      if (result.stderr.toString().isNotEmpty) {
        output.addAll(result.stderr.toString().split('\n'));
      }

      finalContents = File(sampleArbFile).readAsStringSync().trim();
    }

    setUp(() {
      copy(sampleArbFile, '$sampleArbFile.backup', overwrite: true);
    });
    tearDown(() {
      copy('$sampleArbFile.backup', sampleArbFile, overwrite: true);
    });

    test('fails on unknown command', () async {
      runCommand(['bin/arb_utils.dart', 'unknown']);
      expect(
          output.first, contains('Could not find a command named "unknown".'));
    });
    test('generates the metadata', () async {
      runCommand(['bin/arb_utils.dart', 'generate-meta', sampleArbFile]);
      expect(initialContents, isNot(contains('"@noMetadataKey": {}')));
      expect(finalContents, contains('"@noMetadataKey": {}'));
    });
    test('adds a key with human-friendly API', () async {
      // sampleArbFile has @@locale: en
      runCommand([
        'bin/arb_utils.dart',
        'add',
        'myKey',
        '--description',
        'My description',
        'en:My value'
      ]);
      expect(finalContents, contains('"myKey": "My value"'));
      expect(finalContents, contains('"description": "My description"'));
      // Check it's at the end
      final lines = finalContents.split('\n');
      // With pretty printing and trailing newline:
      // {
      //   ...
      //   "myKey": "My value",
      //   "@myKey": {
      //     "description": "My description"
      //   }
      // }
      // \n
      expect(lines[lines.length - 2], contains('}'));
      expect(lines[lines.length - 3], contains('"description": "My description"'));
    });
    test('adds a key with JSON template and placeholder', () async {
      runCommand([
        'bin/arb_utils.dart',
        'add',
        '--json',
        '{"welcome": "\$VAL\$", "@welcome": {"description": "Welcome message"}}',
        'en:Welcome!'
      ]);
      expect(finalContents, contains('"welcome": "Welcome!"'));
      expect(finalContents, contains('"description": "Welcome message"'));
    });
    test('fails if not all locales are provided', () async {
      // Create another arb with a different locale
      const otherArb = 'test/samples/es.arb';
      File(otherArb).writeAsStringSync('{\n  "@@locale": "es"\n}\n');
      try {
        runCommand(['bin/arb_utils.dart', 'add', 'key', 'en:value']);
        expect(output.join('\n'), contains('Missing value for locale: es'));
      } finally {
        File(otherArb).deleteSync();
      }
    });
    test('lists matching keys', () async {
      runCommand(['bin/arb_utils.dart', 'keys', 'metadata']);
      // sampleArbFile contains "metadataKey" and "@metadataKey"
      // "@" keys should be excluded
      expect(output, contains('metadataKey'));
      expect(output, isNot(contains('@metadataKey')));
    });
    test('lists keys with regex', () async {
      runCommand(['bin/arb_utils.dart', 'keys', '^no']);
      expect(output, contains('noMetadataKey'));
      expect(output, isNot(contains('metadataKey')));
    });
    test('sorts an arb file', () async {
      runCommand(['bin/arb_utils.dart', 'sort', sampleArbFile]);
      // "noMetadataKey" should come before "metadataKey" alphabetically if sorted
      // But wait, "metadataKey" starts with 'm', "noMetadataKey" starts with 'n'.
      // 'm' comes before 'n'.
      final mIndex = finalContents.indexOf('"metadataKey":');
      final nIndex = finalContents.indexOf('"noMetadataKey":');
      expect(mIndex, lessThan(nIndex));
    });
    test('merges arb files', () async {
      const arb1 = 'test/samples/merge-1.arb';
      const arb2 = 'test/samples/merge-2.arb';
      const outputArb = 'test/samples/merged_output.arb';
      try {
        runCommand(['bin/arb_utils.dart', 'merge', arb1, arb2, '-o', outputArb]);
        final content = File(outputArb).readAsStringSync();
        expect(content, contains('"newKey": "Test insert of new key"'));
        expect(content, contains('"metadataKey": "Test overwrite of existing key"'));
      } finally {
        if (File(outputArb).existsSync()) {
          File(outputArb).deleteSync();
        }
      }
    });
  });
}
