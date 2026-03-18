// ignore_for_file: deprecated_member_use, sort_children_last

import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/components/productcard.dart';
import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/nav.dart';
import 'package:electralap/services/supabase_service.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

@client
class ProductsPage extends StatefulComponent {
  const ProductsPage({this.selectedBrand, this.selectedCondition, this.selectedPage, this.searchQuery, super.key});

  final String? selectedBrand;
  final String? selectedCondition;
  final String? selectedPage;
  final String? searchQuery;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<StockProduct> _products = const [];
  String _selectedBrand = 'all';
  String _selectedCondition = 'all';
  int _selectedPage = 1;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;
  static const int _pageSize = 9;

  @override
  void initState() {
    super.initState();
    final queryParams = kIsWeb ? Uri.base.queryParameters : const <String, String>{};
    _selectedBrand = _normalizeBrand(queryParams['brand'] ?? component.selectedBrand);
    _selectedCondition = _normalizeCondition(queryParams['condition'] ?? component.selectedCondition);
    _selectedPage = _normalizePage(queryParams['page'] ?? component.selectedPage);
    _searchQuery = _normalizeQuery(queryParams['q'] ?? component.searchQuery);
    if (kIsWeb && _products.isEmpty) {
      _loadProducts();
    }
  }

  void _syncQueryFromUrlIfNeeded() {
    if (!kIsWeb) return;
    final queryParams = Uri.base.queryParameters;
    final nextBrand = _normalizeBrand(queryParams['brand'] ?? component.selectedBrand);
    final nextCondition = _normalizeCondition(queryParams['condition'] ?? component.selectedCondition);
    final nextPage = _normalizePage(queryParams['page'] ?? component.selectedPage);
    final nextQuery = _normalizeQuery(queryParams['q'] ?? component.searchQuery);

    if (nextBrand != _selectedBrand ||
        nextCondition != _selectedCondition ||
        nextPage != _selectedPage ||
        nextQuery != _searchQuery) {
      _selectedBrand = nextBrand;
      _selectedCondition = nextCondition;
      _selectedPage = nextPage;
      _searchQuery = nextQuery;
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

  String _normalizeBrand(String? value) {
    final normalized = (value ?? 'all').trim().toLowerCase();
    const allowed = {'all', 'dell', 'hp', 'lenovo', 'macbook'};
    return allowed.contains(normalized) ? normalized : 'all';
  }

  String _normalizeCondition(String? value) {
    final normalized = (value ?? 'all').trim().toLowerCase();
    const allowed = {'all', 'a++'};
    return allowed.contains(normalized) ? normalized : 'all';
  }

  int _normalizePage(String? value) {
    final page = int.tryParse((value ?? '1').trim()) ?? 1;
    return page < 1 ? 1 : page;
  }

  String _normalizeQuery(String? value) {
    return (value ?? '').trim().toLowerCase();
  }

  List<StockProduct> get _filteredProducts {
    return _products.where((product) {
      final brandMatch = _selectedBrand == 'all' || _matchesBrand(product.productName, _selectedBrand);
      final conditionMatch =
          _selectedCondition == 'all' || product.condition.trim().toLowerCase() == _selectedCondition;
      final query = _searchQuery;
      final queryMatch = query.isEmpty ||
          product.productName.toLowerCase().contains(query) ||
          product.productConfig.toLowerCase().contains(query);
      return brandMatch && conditionMatch && queryMatch;
    }).toList(growable: false);
  }

  int get _totalPages {
    final total = _filteredProducts.length;
    final pages = (total / _pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  int get _currentPage => _selectedPage > _totalPages ? _totalPages : _selectedPage;

  List<StockProduct> get _pagedProducts {
    final filtered = _filteredProducts;
    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    if (start >= filtered.length) return const [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  String _productsUrl({required int page}) {
    final query = <String, String>{};
    if (_selectedBrand != 'all') query['brand'] = _selectedBrand;
    if (_selectedCondition != 'all') query['condition'] = _selectedCondition;
    if (_searchQuery.isNotEmpty) query['q'] = _searchQuery;
    if (page > 1) query['page'] = '$page';
    return Uri(path: NavPaths.products, queryParameters: query.isEmpty ? null : query).toString();
  }

  String _productsUrlFor({
    String? brand,
    String? condition,
    String? query,
    int? page,
  }) {
    final nextBrand = _normalizeBrand(brand ?? _selectedBrand);
    final nextCondition = _normalizeCondition(condition ?? _selectedCondition);
    final nextQuery = _normalizeQuery(query ?? _searchQuery);
    final nextPage = page ?? 1;

    final params = <String, String>{};
    if (nextBrand != 'all') params['brand'] = nextBrand;
    if (nextCondition != 'all') params['condition'] = nextCondition;
    if (nextQuery.isNotEmpty) params['q'] = nextQuery;
    if (nextPage > 1) params['page'] = '$nextPage';
    return Uri(path: NavPaths.products, queryParameters: params.isEmpty ? null : params).toString();
  }

  Component _pagination() {
    if (_totalPages <= 1) return div([]);

    final buttons = <Component>[];

    buttons.add(
      Link(
        to: _productsUrl(page: _currentPage > 1 ? _currentPage - 1 : 1),
        classes: _currentPage == 1 ? 'page-btn disabled' : 'page-btn',
        child: text('Prev'),
      ),
    );

    for (var page = 1; page <= _totalPages; page++) {
      buttons.add(
        Link(
          to: _productsUrl(page: page),
          classes: page == _currentPage ? 'page-btn active' : 'page-btn',
          child: text('$page'),
        ),
      );
    }

    buttons.add(
      Link(
        to: _productsUrl(page: _currentPage < _totalPages ? _currentPage + 1 : _totalPages),
        classes: _currentPage == _totalPages ? 'page-btn disabled' : 'page-btn',
        child: text('Next'),
      ),
    );

    return div(classes: 'pagination-row', buttons);
  }

  bool _matchesBrand(String productName, String brand) {
    final name = productName.toLowerCase();
    switch (brand) {
      case 'dell':
        return name.contains('dell');
      case 'hp':
        return name.contains('hp') || name.contains('hewlett');
      case 'lenovo':
        return name.contains('lenovo') || name.contains('thinkpad');
      case 'macbook':
        return name.contains('macbook') || name.contains('apple');
      default:
        return true;
    }
  }

  Component _productsContent() {
    final products = _pagedProducts;

    if (_isLoading) {
      return div(classes: 'products-empty', [text('Loading products...')]);
    }

    if (_error != null) {
      return div(classes: 'products-empty', [text(_error!)]);
    }

    if (products.isEmpty) {
      return div(classes: 'products-empty', [text('No products found.')]);
    }

    return div([
      div(classes: 'products-grid products-grid-page', [
        ...products.map((product) => ProductCard.fromModel(product: product)),
      ]),
      _pagination(),
    ]);
  }

  @override
  Component build(BuildContext context) {
    _syncQueryFromUrlIfNeeded();
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'products-page-main', [
          div(classes: 'container', [
            h1(classes: 'products-title', [text('All Laptops')]),
            p(classes: 'products-subtitle', [text('${_filteredProducts.length} certified devices available')]),
            div(classes: 'products-page-layout', [
              aside(classes: 'filters-panel', [
                h3([
                  span(classes: 'material-symbols-outlined', [text('tune')]),
                  text('Filters'),
                ]),
                div(classes: 'filter-group', [
                  p(classes: 'filter-label', [text('Brand')]),
                  select(
                    [
                      option([text('All Brands')],
                          value: _productsUrlFor(brand: 'all', page: 1), selected: _selectedBrand == 'all'),
                      option([text('Dell')],
                          value: _productsUrlFor(brand: 'dell', page: 1), selected: _selectedBrand == 'dell'),
                      option([text('HP')],
                          value: _productsUrlFor(brand: 'hp', page: 1), selected: _selectedBrand == 'hp'),
                      option([text('Lenovo')],
                          value: _productsUrlFor(brand: 'lenovo', page: 1), selected: _selectedBrand == 'lenovo'),
                      option([text('MacBook')],
                          value: _productsUrlFor(brand: 'macbook', page: 1), selected: _selectedBrand == 'macbook'),
                    ],
                    classes: 'fake-select brand-select',
                    attributes: {'onchange': 'window.location.href = this.value'},
                  ),
                  div(classes: 'filter-group', [
                    p(classes: 'filter-label', [text('Condition')]),
                    select(
                      [
                        option([text('All Conditions')],
                            value: _productsUrlFor(condition: 'all', page: 1),
                            selected: _selectedCondition == 'all'),
                        option([text('A++')],
                            value: _productsUrlFor(condition: 'a++', page: 1),
                            selected: _selectedCondition == 'a++'),
                      ],
                      classes: 'fake-select brand-select',
                      attributes: {'onchange': 'window.location.href = this.value'},
                    ),
                  ]),
                ]),
                Link(
                  to: NavPaths.products,
                  classes: 'reset-btn',
                  child: text('Reset Filters'),
                ),
              ]),
              div([
                div(classes: 'products-toolbar', [
                  p([text('Showing ${_filteredProducts.length} results • Page $_currentPage of $_totalPages')]),
                ]),
                _productsContent(),
              ]),
            ]),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}
