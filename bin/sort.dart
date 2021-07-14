import 'dart:io';

import 'package:arb_utils/arb_utils.dart';
import 'package:args/args.dart';
import 'package:collection/collection.dart';

const String caseInsensitive = 'case-insensitive';
const String naturalOrdering = 'natural-ordering';
const String descending = 'descending';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addFlag(caseInsensitive, abbr: 'c');
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
  arbContents = sortARB(
    arbContents,
    (A, B) => sort(A, B, result[caseInsensitive], result[naturalOrdering],
        result[descending]),
  );

  await file.writeAsString(arbContents);
}

int sort(String A, String B, bool isCaseInsensitive, bool isNaturalOrdering,
    bool isDescending) {
  var ascending = 1;
  if (isDescending) {
    ascending = -1;
  }
  if (isCaseInsensitive) {
    A = A.toLowerCase();
    B = B.toLowerCase();
  }

  if (isNaturalOrdering) {
    return ascending * compareNatural(A, B);
  } else {
    return ascending * A.compareTo(B);
  }
}
