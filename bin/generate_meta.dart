import 'dart:io';

import 'package:arb_utils/arb_utils.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('ERROR! Expected filepath to arb file.');
    exit(0);
  } else if (args.length > 1) {
    print('WARNING! Ignoring excess arguments ${args.sublist(1)}');
  }

  final file = File(args.first);
  if (!await file.exists()) {
    print('ERROR! File ${file.path} does not exists');
    exit(0);
  }

  var arbContents = await file.readAsString();
  arbContents = addMissingMetadata(arbContents);

  await file.writeAsString(arbContents);
}
