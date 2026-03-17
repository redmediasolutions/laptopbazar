// ignore_for_file: deprecated_member_use

import 'package:electralap/services/cart_store.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class CartBadge extends StatelessComponent {
  const CartBadge({super.key});

  @override
  Component build(BuildContext context) {
    final count = CartStore.getTotalCount();
    return span(classes: 'cart-count', [text(count == 0 ? '0' : '$count')]);
  }
}
