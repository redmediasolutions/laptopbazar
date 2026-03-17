// ignore_for_file: deprecated_member_use

import 'package:electralap/models/stock_product.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

Component cartItem({
  required String image,
  required String name,
  required String condition,
  required double? salePrice,
  required String qty,
  required VoidCallback onIncrement,
  required VoidCallback onDecrement,
  required VoidCallback onRemove,
}) {
  return div(classes: 'cart-item', [
    img(src: image, classes: 'cart-item-image'),
    div(classes: 'cart-item-info', [
      h3([text(name)]),
      p([text(condition)]),
      div(classes: 'qty-control', [
        button(onClick: onDecrement, [text('-')]),
        span([text(qty)]),
        button(onClick: onIncrement, [text('+')]),
      ]),
    ]),
    div(classes: 'cart-item-right', [
      span(classes: 'cart-price', [text(StockProduct.formatPrice(salePrice))]),
      button(classes: 'trash-btn', onClick: onRemove, [
        span(classes: 'material-symbols-outlined', [text('delete')]),
      ]),
    ]),
  ]);
}
