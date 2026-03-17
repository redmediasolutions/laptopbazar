// ignore_for_file: deprecated_member_use

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

Component featureItem(String icon, String title, String subtitle) {
  return div(classes: 'feature-item', [
    div(classes: 'feature-icon', [
      span(classes: 'material-symbols-outlined', [text(icon)]),
    ]),
    div(classes: 'feature-copy', [
      h3([text(title)]),
      p([text(subtitle)]),
    ]),
  ]);
}

