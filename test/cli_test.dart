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
    test('adds a key to a specific file', () async {
      // Ensure we use the backup to have a clean state, although setUp does it
      copy('$sampleArbFile.backup', sampleArbFile, overwrite: true);

      runCommand([
        'bin/arb_utils.dart',
        'add',
        '{"new_key":"new_value"}',
        sampleArbFile
      ]);
      expect(initialContents, isNot(contains('"new_key": "new_value"')));
      expect(finalContents, contains('"new_key": "new_value"'));
    });
    test('adds a key to all .arb files in directory', () async {
      // Create a temporary arb file in a subdirectory
      const subDir = 'test/samples/subdir';
      const subArbFile = '$subDir/test.arb';
      if (!exists(subDir)) {
        createDir(subDir, recursive: true);
      }
      subArbFile.write('{}');

      try {
        // Run add command without specifying files, it should find sampleArbFile and subArbFile
        // But wait, sampleArbFile is test/samples/unsorted.arb.
        // If we run from root, it will find all .arb files.
        runCommand(['bin/arb_utils.dart', 'add', '{"auto_key":"auto_value"}']);

        expect(read(sampleArbFile).toList().join('\n'),
            contains('"auto_key": "auto_value"'));
        expect(read(subArbFile).toList().join('\n'),
            contains('"auto_key": "auto_value"'));
      } finally {
        if (exists(subDir)) {
          deleteDir(subDir, recursive: true);
        }
      }
    });
  });
}
