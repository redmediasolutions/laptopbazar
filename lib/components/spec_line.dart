// ignore_for_file: deprecated_member_use

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

Component specLine(String label, String value) {
  return div(classes: 'spec-row', [
    span([text(label)]),
    span([text(value)]),
  ]);
}

