import 'dart:io';

import 'package:arb_utils/arb_utils.dart';

void gatherNewKeys() {
  var mainARB = File('lib/l10n/intl_en.arb');
  var oldARB = File('lib/l10n/old_translations/intl_en.arb');
  var diffed = diffARBs(mainARB.readAsStringSync(), oldARB.readAsStringSync());
  var newARB = File('lib/l10n/new_translations/intl_en.arb');
  newARB.writeAsStringSync(sortARB(diffed));
}

void gatherNewAndEditedKeys() {
  Process.runSync('git', 'checkout latestVersionBranch'.split(' '));
  var mainARBOld = File('lib/l10n/intl_en.arb').readAsStringSync();
  Process.runSync('git', 'checkout master'.split(' '));
  var mainARBNew = File('lib/l10n/intl_en.arb').readAsStringSync();
  File('lib/l10n/new_translations/intl_en.arb')
      .writeAsStringSync(sortARB(processNewKeys(mainARBNew, mainARBOld)));
}

void mergeNewTranslations() {
  var mainARB = File('lib/l10n/intl_en.arb');
  var newARB = File('lib/l10n/new_translations/intl_en.arb');
  var merged = mergeARBs(mainARB.readAsStringSync(), newARB.readAsStringSync());
  mainARB.writeAsStringSync(sortARB(merged));
}
