// ignore_for_file: deprecated_member_use

import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class ProductCard extends StatelessComponent {
  const ProductCard({
    required this.stockId,
    required this.title,
    required this.specs,
    required this.condition,
    required this.discount,
    required this.image,
    this.salePrice,
    this.oldPrice,
    this.rating,
    super.key,
  });

  factory ProductCard.fromModel({
    required StockProduct product,
    String discount = '',
    String? rating,
    String? oldPrice,
    Key? key,
  }) {
    return ProductCard(
      key: key,
      stockId: product.stockId,
      title: product.productName,
      specs: product.productConfig,
      condition: product.condition,
      discount: discount.isEmpty ? 'BEST VALUE' : discount,
      image: product.productImage,
      salePrice: product.salePrice,
      rating: rating,
      oldPrice: oldPrice,
    );
  }

  final int stockId;
  final String title;
  final String specs;
  final String condition;
  final String discount;
  final String image;
  final double? salePrice;
  final String? oldPrice;
  final String? rating;

  @override
  Component build(BuildContext context) {
    return div(classes: 'product-card', [
      Link(to: NavPaths.productDetailById(stockId), classes: 'product-link', children: [
        div(classes: 'product-image-wrap', [
          img(src: image),
          span(classes: 'discount-badge', [text(discount)]),
        ]),
        div(classes: 'product-body', [
          div(classes: 'product-meta', [
            span(classes: 'condition-pill', [text(condition)]),
            if (rating != null)
              span(classes: 'rating', [
                span(classes: 'material-symbols-outlined', [text('star')]),
                text(' $rating'),
              ]),
          ]),
          h3([text(title)]),
          p(classes: 'specs', [text(specs)]),
        ]),
      ]),
      div(classes: 'product-body product-body-footer', [
        div(classes: 'price-row', [
          span(
            classes: 'contact-price-link',
            [text(StockProduct.formatPrice(salePrice))],
          ),
        ]),
      ]),
    ]);
  }
}
