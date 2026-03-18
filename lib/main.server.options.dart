// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:electralap/components/add_to_cart_button.dart'
    as _add_to_cart_button;
import 'package:electralap/components/cart_badge.dart' as _cart_badge;
import 'package:electralap/components/cart_items_panel.dart'
    as _cart_items_panel;
import 'package:electralap/pages/checkout.dart' as _checkout;
import 'package:electralap/pages/productdetail.dart' as _productdetail;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _add_to_cart_button.AddToCartButton:
        ClientTarget<_add_to_cart_button.AddToCartButton>(
          'add_to_cart_button',
          params: __add_to_cart_buttonAddToCartButton,
        ),
    _cart_badge.CartBadge: ClientTarget<_cart_badge.CartBadge>('cart_badge'),
    _cart_items_panel.CartItemsPanel:
        ClientTarget<_cart_items_panel.CartItemsPanel>(
          'cart_items_panel',
          params: __cart_items_panelCartItemsPanel,
        ),
    _checkout.CheckoutScreen: ClientTarget<_checkout.CheckoutScreen>(
      'checkout',
    ),
    _productdetail.ProductDetailPage:
        ClientTarget<_productdetail.ProductDetailPage>(
          'productdetail',
          params: __productdetailProductDetailPage,
        ),
  },
);

Map<String, Object?> __add_to_cart_buttonAddToCartButton(
  _add_to_cart_button.AddToCartButton c,
) => {
  'stockId': c.stockId,
  'name': c.name,
  'image': c.image,
  'condition': c.condition,
  'config': c.config,
  'salePrice': c.salePrice,
};
Map<String, Object?> __cart_items_panelCartItemsPanel(
  _cart_items_panel.CartItemsPanel c,
) => {'stockId': c.stockId};
Map<String, Object?> __productdetailProductDetailPage(
  _productdetail.ProductDetailPage c,
) => {'stockId': c.stockId};
