import 'dart:io';

import 'package:arb_utils/arb_utils.dart';

void gatherNewKeys(){

  var mainARB = File('lib/l10n/intl_en.arb');
  var oldARB = File('lib/l10n/old_translations/intl_en.arb');
  var diffed = diffARBs(mainARB.readAsStringSync(), oldARB.readAsStringSync());
  var newARB = File('lib/l10n/new_translations/intl_en.arb');
  newARB.writeAsStringSync(diffed);
}

void mergeNewTranslations() {
  var mainARB = File('lib/l10n/intl_en.arb');
  var newARB = File('lib/l10n/new_translations/intl_en.arb');
  var merged = mergeARBs(mainARB.readAsStringSync(), newARB.readAsStringSync());
  mainARB.writeAsStringSync(merged);
}
