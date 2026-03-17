// ignore_for_file: deprecated_member_use

import 'package:electralap/components/feature_item.dart';
import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/components/productcard.dart';
import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/nav.dart';
import 'package:electralap/services/supabase_service.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
class HomePage extends StatefulComponent {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PreloadStateMixin<HomePage> {
  List<StockProduct> _products = const [];
  bool _isLoading = true;
  String? _error;

  @override
  Future<void> preloadState() async {
    try {
      _products = await SupabaseService.fetchProducts();
      _isLoading = false;
      _error = null;
    } catch (_) {
      _isLoading = false;
      _error = 'Unable to load products from database.';
    }
  }

  @override
  void initState() {
    super.initState();
    if (_products.isEmpty) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await SupabaseService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Unable to load products from database.';
      });
    }
  }

  Component _productGrid(Iterable<StockProduct> products) {
    final items = products.toList(growable: false);

    if (_isLoading) {
      return div(classes: 'products-empty', [text('Loading products...')]);
    }

    if (_error != null) {
      return div(classes: 'products-empty', [text(_error!)]);
    }

    if (items.isEmpty) {
      return div(classes: 'products-empty', [text('No products found.')]);
    }

    return div(classes: 'products-grid', [
      ...items.map((product) => ProductCard.fromModel(product: product)),
    ]);
  }

  @override
  Component build(BuildContext context) {
    final trending = _products.take(3);
    final bestDeals = _products.skip(3).take(3);

    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'hero-section', [
          div(classes: 'container hero', [
            div(classes: 'hero-content', [
              span(classes: 'chip', [text(' Trusted Refurbished Laptops')]),
              h1([
                text('Get your dream'),
                br(),
                span(classes: 'highlight', [text('Laptop at Best Price')]),
              ]),
              p([
                text(
                    'Buy premium laptops at budget-friendly prices for students, freelancers, and professionals across India. Every device is tested, certified and backed with service support.'),
              ]),
              div(classes: 'hero-actions', [
                Link(to: NavPaths.products, classes: 'btn btn-primary', children: [
                  text('Shop Now'),
                  span(classes: 'material-symbols-outlined', [text('arrow_forward')]),
                ]),
                Link(to: NavPaths.about, classes: 'btn btn-ghost', child: text('Learn More')),
              ]),
            ]),
            div(classes: 'hero-image-wrap', [
              img(
                src:
                    'https://images.unsplash.com/photo-1486946255434-2466348c2166?auto=format&fit=crop&w=1400&q=80',
                classes: 'hero-image',
              ),
            ]),
          ]),
        ]),
        section(classes: 'features-strip', [
          div(classes: 'container features-grid', [
            featureItem('shield', '6-Month Warranty', 'Reliable support on every laptop'),
           // featureItem('bolt', 'Fast Shipping', 'Free delivery across India in 3-5 days'),
            featureItem('memory', 'Certified Quality', '40+ quality checks before dispatch'),
            featureItem('schedule', 'Easy Returns', '7-day return support for peace of mind'),
          ]),
        ]),
        section(classes: 'products-section', [
          div(classes: 'container', [
            div(classes: 'products-header', [
              div([
                span(classes: 'chip', [text('Most Loved')]),
                h2([text('Trending this week')]),
              ]),
              Link(to: NavPaths.products, classes: 'view-all', children: [
                text('View All'),
                span(classes: 'material-symbols-outlined', [text('arrow_forward')]),
              ]),
            ]),
            _productGrid(trending),
          ]),
        ]),
        section(classes: 'products-section', [
          div(classes: 'container', [
            div(classes: 'products-header', [
              div([
                span(classes: 'chip', [text('Top Savings')]),
                h2([text('Best Deals')]),
              ]),
              Link(to: NavPaths.products, classes: 'view-all', children: [
                text('View All'),
                span(classes: 'material-symbols-outlined', [text('arrow_forward')]),
              ]),
            ]),
            _productGrid(bestDeals),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}
