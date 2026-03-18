// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:electralap/components/add_to_cart_button.dart'
    deferred as _add_to_cart_button;
import 'package:electralap/components/cart_badge.dart' deferred as _cart_badge;
import 'package:electralap/components/cart_items_panel.dart'
    deferred as _cart_items_panel;
import 'package:electralap/pages/checkout.dart' deferred as _checkout;
import 'package:electralap/pages/productdetail.dart' deferred as _productdetail;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'add_to_cart_button': ClientLoader(
      (p) => _add_to_cart_button.AddToCartButton(
        stockId: p['stockId'] as int,
        name: p['name'] as String,
        image: p['image'] as String,
        condition: p['condition'] as String,
        config: p['config'] as String,
        salePrice: p['salePrice'] as double?,
      ),
      loader: _add_to_cart_button.loadLibrary,
    ),
    'cart_badge': ClientLoader(
      (p) => _cart_badge.CartBadge(),
      loader: _cart_badge.loadLibrary,
    ),
    'cart_items_panel': ClientLoader(
      (p) => _cart_items_panel.CartItemsPanel(stockId: p['stockId'] as int?),
      loader: _cart_items_panel.loadLibrary,
    ),
    'checkout': ClientLoader(
      (p) => _checkout.CheckoutScreen(),
      loader: _checkout.loadLibrary,
    ),
    'productdetail': ClientLoader(
      (p) => _productdetail.ProductDetailPage(stockId: p['stockId'] as int?),
      loader: _productdetail.loadLibrary,
    ),
  },
);
