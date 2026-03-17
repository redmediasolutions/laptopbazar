// ignore_for_file: deprecated_member_use

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

Component pdpBenefit(String icon, String title, String subtitle) {
  return div(classes: 'pdp-benefit', [
    span(classes: 'material-symbols-outlined', [text(icon)]),
    div([
      h4([text(title)]),
      p([text(subtitle)]),
    ]),
  ]);
}

