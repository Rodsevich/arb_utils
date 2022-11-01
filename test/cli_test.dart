import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  group('Tests for the CLI ', () {
    const sampleArbFile = 'test/samples/unsorted.arb';
    var initialContents = '';
    var finalContents = '';
    var output = <String>[];

    void run_command(String command) {
      final initialBuffer = StringBuffer();
      final finalBuffer = StringBuffer();
      read(sampleArbFile).forEach((line) {
        initialBuffer.writeln(line);
      });
      initialContents = initialBuffer.toString();
      output = command.start().lines;
      read(sampleArbFile).forEach((line) {
        finalBuffer.writeln(line);
      });
      finalContents = finalBuffer.toString();
    }

    setUp(() {
      copy(sampleArbFile, '$sampleArbFile.backup', overwrite: true);
    });
    tearDown(() {
      copy('$sampleArbFile.backup', sampleArbFile, overwrite: true);
    });

    test('fails on unknown command', () async {
      run_command('dart bin/arb_utils.dart unknown');
      expect(
          output.first, contains('Could not find a command named "unknown".'));
    });
    test('generates the metadata', () async {
      run_command('dart bin/arb_utils.dart generate-meta $sampleArbFile');
      expect(initialContents, isNot(contains('"@noMetadataKey": {}')));
      expect(finalContents, contains('"@noMetadataKey": {}'));
    });
  });
}
