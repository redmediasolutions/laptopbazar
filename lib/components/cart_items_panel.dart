// ignore_for_file: deprecated_member_use

import 'package:electralap/components/cart_item.dart';
import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/cart_store.dart';
import 'package:electralap/services/supabase_service.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class CartItemsPanel extends StatefulComponent {
  const CartItemsPanel({this.stockId, super.key});

  final int? stockId;

  @override
  State<CartItemsPanel> createState() => _CartItemsPanelState();
}

class _CartItemsPanelState extends State<CartItemsPanel> {
  List<CartItemData> _items = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.microtask(() {
        CartStore.consumePendingProduct();
        final stockId = component.stockId;
        if (stockId != null && stockId > 0) {
          SupabaseService.fetchProductByStockId(stockId).then((product) {
            if (product != null) {
              CartStore.addProduct(product);
            }
            _loadCart();
          }).catchError((_) {
            _loadCart();
          });
        } else {
          _loadCart();
        }
      });
    } else {
      _loadCart(preload: true);
    }
  }

  Future<void> _loadCart({bool preload = false}) async {
    final items = CartStore.getItemsList();
    if (items.isEmpty && component.stockId != null && component.stockId! > 0) {
      await _loadFromStockId(component.stockId!, preload: preload);
      return;
    }
    if (preload) {
      _items = items;
      _isLoading = false;
    } else {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFromStockId(int stockId, {bool preload = false}) async {
    StockProduct? product;
    try {
      product = await SupabaseService.fetchProductByStockId(stockId);
    } catch (_) {
      product = null;
    }
    if (product == null) {
      if (preload) {
        _items = const [];
        _isLoading = false;
      } else {
        setState(() {
          _items = const [];
          _isLoading = false;
        });
      }
      return;
    }

    if (kIsWeb && !preload) {
      CartStore.addProduct(product);
    }

    final item = CartItemData(
      stockId: product.stockId,
      name: product.productName,
      image: product.productImage,
      condition: product.condition,
      config: product.productConfig,
      salePrice: product.salePrice,
      qty: 1,
    );

    if (preload) {
      _items = [item];
      _isLoading = false;
    } else {
      setState(() {
        _items = [item];
        _isLoading = false;
      });
    }
  }

  void _refreshItems() {
    setState(() {
      _items = CartStore.getItemsList();
    });
  }

  List<Component> _cartItems() {
    if (_isLoading) {
      return [div(classes: 'products-empty', [text('Loading cart...')])];
    }

    if (_items.isEmpty) {
      return [
        div(classes: 'products-empty', [
          text('Your cart is empty. Add products from the product detail page.'),
        ]),
      ];
    }

    return _items
        .map(
          (item) => cartItem(
            image: item.image,
            name: item.name,
            condition: item.condition,
            salePrice: item.salePrice,
            qty: '${item.qty}',
            onIncrement: () {
              CartStore.incrementProduct(item.stockId);
              _refreshItems();
            },
            onDecrement: () {
              CartStore.decrementProduct(item.stockId);
              _refreshItems();
            },
            onRemove: () {
              CartStore.removeProduct(item.stockId);
              _refreshItems();
            },
          ),
        )
        .toList(growable: false);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'cart-items', _cartItems());
  }
}
