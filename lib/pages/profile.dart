// ignore_for_file: deprecated_member_use

import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/components/spec_line.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class ProfilePage extends StatelessComponent {
  const ProfilePage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'products-page-main', [
          div(classes: 'container', [
            h1(classes: 'products-title', [text('My Profile')]),
            p(classes: 'products-subtitle', [text('Manage your ELECTRALAP account details')]),
            div(classes: 'spec-card', [
              specLine('Name', 'Keerthan Rao'),
              specLine('Email', 'keerthanrao8@gmail.com'),
              specLine('Phone', '+91 98765 43210'),
              specLine('City', 'Mangalore'),
              specLine('Member Since', '2026'),
            ]),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}
