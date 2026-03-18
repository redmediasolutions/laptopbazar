// ignore_for_file: deprecated_member_use

import 'package:electralap/components/add_to_cart_button.dart';
import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/components/pdp_benefit.dart';
import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/nav.dart';
import 'package:electralap/services/supabase_service.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

@client
class ProductDetailPage extends StatefulComponent {
  const ProductDetailPage({required this.stockId, super.key});

  final int? stockId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  StockProduct? _product;
  bool _isLoading = true;
  String? _error;
  int? _resolvedStockId;

  @override
  void initState() {
    super.initState();
    _resolvedStockId = component.stockId;
    if (_resolvedStockId == null && kIsWeb) {
      _resolvedStockId = int.tryParse(Uri.base.queryParameters['stockId'] ?? '');
    }
    if (kIsWeb && _product == null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    final stockId = _resolvedStockId ?? component.stockId;
    if (stockId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Invalid product link.';
      });
      return;
    }

    try {
      final product = await SupabaseService.fetchProductByStockId(stockId);
      setState(() {
        _product = product;
        _isLoading = false;
        _error = product == null ? 'Product not found.' : null;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load product details.';
      });
    }
  }


  Component _buildBody(BuildContext context) {
    if (_isLoading) {
      return div(classes: 'products-empty', [text('Loading product...')]);
    }

    if (_error != null) {
      return div(classes: 'products-empty', [text(_error!)]);
    }

    final product = _product;
    if (product == null) {
      return div(classes: 'products-empty', [text('Product not found.')]);
    }

    return div(classes: 'container', [
      div(classes: 'breadcrumb', [
        Link(to: NavPaths.home, child: text('Home')),
        text(' / '),
        Link(to: NavPaths.products, child: text('Products')),
        text(' / '),
        span([text(product.productName)]),
      ]),
      div(classes: 'pdp-layout', [
        div([
          div(classes: 'pdp-image-wrap', [
            span(classes: 'stock-badge', [text('In Stock')]),
            img(src: product.productImage, classes: 'pdp-image'),
          ]),
        ]),
        div(classes: 'pdp-info', [
          h1([text(product.productName)]),
          div(
            classes: 'pdp-add-btn pdp-contact-btn',
            [
              span(classes: 'material-symbols-outlined', [text('sell')]),
              text(StockProduct.formatPrice(product.salePrice)),
            ],
          ),
          p(classes: 'pdp-desc', [
            text(
              'The ${product.productName} delivers premium performance for creators and professionals in India. This unit is fully tested and shipped with GST billing support.',
            ),
          ]),
          AddToCartButton(
            stockId: _resolvedStockId ?? product.stockId,
            name: product.productName,
            image: product.productImage,
            condition: product.condition,
            config: product.productConfig,
            salePrice: product.salePrice,
          ),
          div(classes: 'pdp-benefits', [
            pdpBenefit('shield', '6-Month Warranty', 'Pan-India service support'),
           // pdpBenefit('local_shipping', 'Free Shipping', 'Delivery across India in 3-5 days'),
            pdpBenefit('cycle', 'Easy Returns', '7-day return assistance'),
          ]),
        ]),
      ]),
      section(classes: 'pdp-specs', [
        div(classes: 'spec-tabs', [
          button(classes: 'tab active', [text('Specifications')]),
        ]),
        div(classes: 'spec-card', [
          p(classes: 'spec-single-line', [text(product.productConfig)]),
        ]),
      ]),
    ]);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'pdp-main', [_buildBody(context)]),
      ]),
      const AppFooter(),
    ]);
  }
}
