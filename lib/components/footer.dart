// ignore_for_file: deprecated_member_use

import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class AppFooter extends StatelessComponent {
  const AppFooter({super.key});

  @override
  Component build(BuildContext context) {
    return footer(classes: 'site-footer', [
      div(classes: 'container', [
        div(classes: 'footer-grid', [
          div(classes: 'footer-col', [
            div(classes: 'brand footer-brand', [
              span(classes: 'logo-box', [
                span(classes: 'material-symbols-outlined', [text('bolt')]),
              ]),
              span([text('ELECTRALAP')]),
            ]),
            p([text('India laptop marketplace for certified refurbished devices at honest prices.')]),
          ]),
          div(classes: 'footer-col', [
            h3([text('Products')]),
            Link(to: '${NavPaths.products}?brand=macbook', child: text('MacBooks')),
            Link(to: '${NavPaths.products}?brand=dell', child: text('Dell')),
            Link(to: '${NavPaths.products}?brand=lenovo', child: text('Lenovo')),
            Link(to: '${NavPaths.products}?brand=hp', child: text('HP')),
          ]),
        //   div(classes: 'footer-col', [
        //     h3([text('Company')]),
        //     Link(to: NavPaths.about, child: text('About Us')),
        //     Link(to: NavPaths.contact, child: text('Contact')),
        //   ]),
         ]),
        // div(classes: 'copyright', [
        //   text('Designed and developed by '),
        //   a(
        //     href: 'https://redmediasolutions.in/',
        //     classes: 'credit-link',
        //     attributes: {'target': '_blank', 'rel': 'noopener noreferrer'},
        //     [
        //       text('Red Media Solutions'),
        //       span(classes: 'material-symbols-outlined', [text('north_east')]),
        //     ],
        //   ),
        // ]),
      ]),
    ]);
  }
}
