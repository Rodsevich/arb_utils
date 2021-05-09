import 'dart:io';

import 'package:arb_utils/arb_utils.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('ERROR! Expected filepath to arb file.');
    exit(0);
  } else if (args.length > 1) {
    print('WARNING! Ignoring excess arguments ${args.sublist(1)}');
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    print('ERROR! File ${args.first} does not exists');
    exit(0);
  }

  final arbContents = file.readAsStringSync();
  final sortedContents = sortARB(arbContents);

  file.writeAsStringSync(sortedContents);
}
