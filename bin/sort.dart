import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/args.dart';

const String caseInsensitive = 'case-Insensitive';
const String naturalOrdering = 'Natural-ordering';
const String descending = 'Descending';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag(caseInsensitive, abbr: 'i');
  parser.addFlag(naturalOrdering, abbr: 'n');
  parser.addFlag(descending, abbr: 'd');
  var result = parser.parse(args);
  if (result.rest.isEmpty) {
    print('ERROR! Expected filepath to arb file.');
    exit(0);
  } else if (result.rest.length > 1) {
    print('WARNING! Ignoring excess arguments ${result.rest.sublist(1)}');
  }

  final file = File(result.rest.first);
  if (!await file.exists()) {
    print('ERROR! File ${file.path} does not exists');
    exit(0);
  }

  var arbContents = await file.readAsString();
  arbContents = sortARB(arbContents,
      caseInsensitive: result[caseInsensitive],
      naturalOrdering: result[naturalOrdering],
      descendingOrdering: result[descending]);

  await file.writeAsString(arbContents);
}
