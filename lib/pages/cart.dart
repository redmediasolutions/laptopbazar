// ignore_for_file: deprecated_member_use

import 'package:electralap/components/cart_items_panel.dart';
import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class CartPage extends StatelessComponent {
  const CartPage({this.stockId, super.key});

  final int? stockId;

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'cart-main', [
          div(classes: 'container', [
            h1(classes: 'cart-title', [text('Your Cart')]),
            div(classes: 'cart-layout', [
              CartItemsPanel(stockId: stockId),
              div(classes: 'summary-card', [
                h2([text('Order Summary')]),
                Link(
                  to: NavPaths.checkout,
                  classes: 'checkout-btn',
                  children: [
                    span(classes: 'material-symbols-outlined', [text('shopping_cart_checkout')]),
                    text('Proceed to Checkout'),
                  ],
                ),
                Link(to: NavPaths.home, classes: 'continue-btn', children: [
                  span(classes: 'material-symbols-outlined', [text('shopping_bag')]),
                  text('Continue Shopping'),
                ]),
              ]),
            ]),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}
