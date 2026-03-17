// ignore_for_file: deprecated_member_use

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

Component summaryLine(String label, String value, {bool isAccent = false}) {
  return div(classes: 'summary-line', [
    span([text(label)]),
    span(classes: isAccent ? 'accent' : null, [text(value)]),
  ]);
}

