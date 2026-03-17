// ignore_for_file: deprecated_member_use

import 'package:electralap/components/cart_badge.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class AppHeader extends StatelessComponent {
  const AppHeader({super.key});

  @override
  Component build(BuildContext context) {
    return header(classes: 'app-header', [
      div(classes: 'container header-inner', [
        Link(to: NavPaths.home, classes: 'brand', children: [
          span(classes: 'logo-box', [
            span(classes: 'material-symbols-outlined', [text('bolt')]),
          ]),
          span([text('ELECTRALAP')]),
        ]),
        form(
          [
            div(classes: 'search-wrap', [
              span(classes: 'material-symbols-outlined search-icon', [text('search')]),
              input(
                classes: 'search-input',
                attributes: {
                  'placeholder': 'Search laptops...',
                  'name': 'q',
                  'aria-label': 'Search laptops',
                },
              ),
            ]),
          ],
          attributes: {'method': 'get', 'action': NavPaths.products},
        ),
        nav(classes: 'header-nav', [
          Link(to: NavPaths.products, classes: 'nav-link', child: text('Products')),
        //  Link(to: NavPaths.about, classes: 'nav-link', child: text('About')),
          Link(to: NavPaths.cart, classes: 'icon-btn cart-btn', children: [
            span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
            const CartBadge(),
          ]),
        ]),
      ]),
    ]);
  }
}
