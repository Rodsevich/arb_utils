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
      // The last line is newline, the one before is closing brace, the one before is our key.
      // Wait, with pretty printing and trailing newline:
      // {
      //   ...
      //   "myKey": "My value"
      // }
      // \n
      expect(finalContents, contains('"myKey": "My value"'));
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
  });
}
