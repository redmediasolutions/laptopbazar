// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:electralap/services/cart_store.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

@client
class AddToCartButton extends StatefulComponent {
  const AddToCartButton({
    required this.stockId,
    required this.name,
    required this.image,
    required this.condition,
    required this.config,
    required this.salePrice,
    super.key,
  });

  final int stockId;
  final String name;
  final String image;
  final String condition;
  final String config;
  final double? salePrice;

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _showCartToast = false;
  Timer? _toastTimer;

  void _showAddedToast() {
    _toastTimer?.cancel();
    setState(() {
      _showCartToast = true;
    });
    _toastTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCartToast = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return div([
      button(
        classes: 'pdp-add-btn',
        onClick: () {
          CartStore.addProductData(
            stockId: component.stockId,
            name: component.name,
            image: component.image,
            condition: component.condition,
            config: component.config,
            salePrice: component.salePrice,
          );
          CartStore.setPendingProductData(
            stockId: component.stockId,
            name: component.name,
            image: component.image,
            condition: component.condition,
            config: component.config,
            salePrice: component.salePrice,
          );
          _showAddedToast();
          Router.of(context).push('${NavPaths.cart}?stockId=${component.stockId}');
        },
        [
          span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
          text('Add to Cart'),
        ],
      ),
      if (_showCartToast)
        div(classes: 'cart-toast', [
          div(classes: 'cart-toast-inner', [
            span(classes: 'material-symbols-outlined', [text('shopping_cart')]),
            div(classes: 'cart-toast-copy', [
              span(classes: 'cart-toast-title', [text('Added to cart')]),
              span(classes: 'cart-toast-sub', [text('Tap View Cart to checkout')]),
            ]),
            Link(to: NavPaths.cart, classes: 'cart-toast-cta', child: text('View Cart')),
          ]),
        ]),
    ]);
  }
}
