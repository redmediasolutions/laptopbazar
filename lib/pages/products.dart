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

class ProductsPage extends StatefulComponent {
  const ProductsPage({this.selectedBrand, this.selectedCondition, this.selectedPage, this.searchQuery, super.key});

  final String? selectedBrand;
  final String? selectedCondition;
  final String? selectedPage;
  final String? searchQuery;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> with PreloadStateMixin<ProductsPage> {
  List<StockProduct> _products = const [];
  late final String _selectedBrand;
  late final String _selectedCondition;
  late final int _selectedPage;
  late final String _searchQuery;
  bool _isLoading = true;
  String? _error;
  static const int _pageSize = 9;

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
    _selectedBrand = _normalizeBrand(component.selectedBrand);
    _selectedCondition = _normalizeCondition(component.selectedCondition);
    _selectedPage = _normalizePage(component.selectedPage);
    _searchQuery = _normalizeQuery(component.searchQuery);
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
                  form(
                    [
                      select(
                        [
                          option([text('All Brands')], value: 'all', selected: _selectedBrand == 'all'),
                          option([text('Dell')], value: 'dell', selected: _selectedBrand == 'dell'),
                          option([text('HP')], value: 'hp', selected: _selectedBrand == 'hp'),
                          option([text('Lenovo')], value: 'lenovo', selected: _selectedBrand == 'lenovo'),
                          option([text('MacBook')], value: 'macbook', selected: _selectedBrand == 'macbook'),
                        ],
                        name: 'brand',
                        classes: 'fake-select brand-select',
                        attributes: {'onchange': 'this.form.submit()'},
                      ),
                      if (_searchQuery.isNotEmpty)
                        input(attributes: {'type': 'hidden', 'name': 'q', 'value': _searchQuery}),
                      div(classes: 'filter-group', [
                        p(classes: 'filter-label', [text('Condition')]),
                        select(
                          [
                            option([text('All Conditions')], value: 'all', selected: _selectedCondition == 'all'),
                            option([text('A++')], value: 'a++', selected: _selectedCondition == 'a++'),
                          ],
                          name: 'condition',
                          classes: 'fake-select brand-select',
                          attributes: {'onchange': 'this.form.submit()'},
                        ),
                        if (_searchQuery.isNotEmpty)
                          input(attributes: {'type': 'hidden', 'name': 'q', 'value': _searchQuery}),
                      ]),
                    ],
                    attributes: {'method': 'get', 'action': NavPaths.products},
                  ),
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
