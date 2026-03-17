// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:electralap/models/stock_product.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

class CartItemData {
  CartItemData({
    required this.stockId,
    required this.name,
    required this.image,
    required this.condition,
    required this.config,
    required this.salePrice,
    required this.qty,
  });

  final int stockId;
  final String name;
  final String image;
  final String condition;
  final String config;
  final double? salePrice;
  final int qty;

  CartItemData copyWith({int? qty}) {
    return CartItemData(
      stockId: stockId,
      name: name,
      image: image,
      condition: condition,
      config: config,
      salePrice: salePrice,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toJson() => {
        'stock_id': stockId,
        'name': name,
        'image': image,
        'condition': condition,
        'config': config,
        'saleprice': salePrice,
        'qty': qty,
      };

  static CartItemData? fromJson(Map<String, dynamic> json) {
    final stockId = json['stock_id'] is num ? (json['stock_id'] as num).toInt() : int.tryParse('${json['stock_id']}');
    if (stockId == null || stockId <= 0) return null;
    final name = '${json['name'] ?? ''}'.trim();
    final image = '${json['image'] ?? ''}'.trim();
    final condition = '${json['condition'] ?? ''}'.trim();
    final config = '${json['config'] ?? ''}'.trim();
    final salepriceRaw = json['saleprice'];
    double? salePrice;
    if (salepriceRaw is num) {
      salePrice = salepriceRaw.toDouble();
    } else if (salepriceRaw != null) {
      salePrice = double.tryParse('$salepriceRaw');
    }
    final qty = json['qty'] is num ? (json['qty'] as num).toInt() : int.tryParse('${json['qty']}') ?? 1;
    if (name.isEmpty) return null;
    return CartItemData(
      stockId: stockId,
      name: name,
      image: image,
      condition: condition.isEmpty ? 'Certified Refurbished' : condition,
      config: config,
      salePrice: salePrice,
      qty: qty <= 0 ? 1 : qty,
    );
  }
}

class CartStore {
  static const String _key = 'electralap_cart_v2';
  static const String _pendingKey = 'electralap_cart_pending';
  static const String _lastKey = 'electralap_cart_last';
  static Map<int, CartItemData> _memory = <int, CartItemData>{};

  static Map<int, CartItemData> getItems() {
    if (!kIsWeb) return Map<int, CartItemData>.from(_memory);
    final raw = web.window.localStorage.getItem(_key);
    if (raw == null || raw.isEmpty) {
      return Map<int, CartItemData>.from(_memory);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return <int, CartItemData>{};
      final list = decoded['items'];
      if (list is! List) return <int, CartItemData>{};

      final items = <int, CartItemData>{};
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) continue;
        final item = CartItemData.fromJson(entry);
        if (item != null) {
          items[item.stockId] = item;
        }
      }
      _memory = items;
      return items;
    } catch (_) {
      return Map<int, CartItemData>.from(_memory);
    }
  }

  static List<CartItemData> getItemsList() {
    return getItems().values.toList(growable: false);
  }

  static int getTotalCount() {
    final items = getItems();
    var total = 0;
    for (final item in items.values) {
      total += item.qty;
    }
    return total;
  }

  static void _saveItems(Map<int, CartItemData> items) {
    _memory = items;
    if (!kIsWeb) return;
    final serializable = <String, dynamic>{
      'items': items.values.map((item) => item.toJson()).toList(growable: false),
    };
    web.window.localStorage.setItem(_key, jsonEncode(serializable));
  }

  static void addProduct(StockProduct product) {
    addProductData(
      stockId: product.stockId,
      name: product.productName,
      image: product.productImage,
      condition: product.condition,
      config: product.productConfig,
      salePrice: product.salePrice,
    );
  }

  static void addProductData({
    required int stockId,
    required String name,
    required String image,
    required String condition,
    required String config,
    required double? salePrice,
  }) {
    if (stockId <= 0) return;
    final items = getItems();
    final existing = items[stockId];
    if (existing == null) {
      items[stockId] = CartItemData(
        stockId: stockId,
        name: name,
        image: image,
        condition: condition,
        config: config,
        salePrice: salePrice,
        qty: 1,
      );
    } else {
      items[stockId] = existing.copyWith(qty: existing.qty + 1);
    }
    _saveItems(items);
    _storeLastItem(
      stockId: stockId,
      name: name,
      image: image,
      condition: condition,
      config: config,
      salePrice: salePrice,
    );
  }

  static void setPendingProduct(StockProduct product) {
    if (!kIsWeb) return;
    setPendingProductData(
      stockId: product.stockId,
      name: product.productName,
      image: product.productImage,
      condition: product.condition,
      config: product.productConfig,
      salePrice: product.salePrice,
    );
  }

  static void setPendingProductData({
    required int stockId,
    required String name,
    required String image,
    required String condition,
    required String config,
    required double? salePrice,
  }) {
    if (!kIsWeb) return;
    final payload = CartItemData(
      stockId: stockId,
      name: name,
      image: image,
      condition: condition,
      config: config,
      salePrice: salePrice,
      qty: 1,
    ).toJson();
    web.window.sessionStorage.setItem(_pendingKey, jsonEncode(payload));
  }

  static void _storeLastItem({
    required int stockId,
    required String name,
    required String image,
    required String condition,
    required String config,
    required double? salePrice,
  }) {
    if (!kIsWeb) return;
    final payload = CartItemData(
      stockId: stockId,
      name: name,
      image: image,
      condition: condition,
      config: config,
      salePrice: salePrice,
      qty: 1,
    ).toJson();
    web.window.localStorage.setItem(_lastKey, jsonEncode(payload));
  }

  static void ensureLastFallback() {
    if (!kIsWeb) return;
    final current = getItems();
    if (current.isNotEmpty) return;
    final raw = web.window.localStorage.getItem(_lastKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      final item = CartItemData.fromJson(decoded);
      if (item == null) return;
      current[item.stockId] = item;
      _saveItems(current);
    } catch (_) {
      return;
    }
  }

  static bool consumePendingProduct() {
    if (!kIsWeb) return false;
    final raw = web.window.sessionStorage.getItem(_pendingKey);
    if (raw == null || raw.isEmpty) return false;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        web.window.sessionStorage.removeItem(_pendingKey);
        return false;
      }
      final item = CartItemData.fromJson(decoded);
      web.window.sessionStorage.removeItem(_pendingKey);
      if (item == null) return false;
      final items = getItems();
      final existing = items[item.stockId];
      if (existing == null) {
        items[item.stockId] = item;
      }
      _saveItems(items);
      return true;
    } catch (_) {
      web.window.sessionStorage.removeItem(_pendingKey);
      return false;
    }
  }

  static void incrementProduct(int stockId) {
    final items = getItems();
    final existing = items[stockId];
    if (existing == null) return;
    items[stockId] = existing.copyWith(qty: existing.qty + 1);
    _saveItems(items);
  }

  static void decrementProduct(int stockId) {
    final items = getItems();
    final existing = items[stockId];
    if (existing == null) return;
    if (existing.qty > 1) {
      items[stockId] = existing.copyWith(qty: existing.qty - 1);
    } else {
      items.remove(stockId);
    }
    _saveItems(items);
  }

  static void removeProduct(int stockId) {
    final items = getItems();
    items.remove(stockId);
    _saveItems(items);
  }

  static void clear() {
    _memory = <int, CartItemData>{};
    if (!kIsWeb) return;
    web.window.localStorage.removeItem(_key);
  }
}
