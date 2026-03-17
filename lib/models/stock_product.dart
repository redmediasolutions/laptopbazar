class StockProduct {
  const StockProduct({
    required this.stockId,
    required this.productName,
    required this.productConfig,
    required this.productImage,
    required this.condition,
    this.salePrice,
    this.productId,
    this.businessId,
    this.vendorId,
    this.vendorName,
    this.isSold,
  });

  final int stockId;
  final String productName;
  final String productConfig;
  final String productImage;
  final String condition;
  final double? salePrice;
  final int? productId;
  final int? businessId;
  final int? vendorId;
  final String? vendorName;
  final bool? isSold;

  static String formatPrice(double? value) {
    final safeValue = value ?? 0;
    final rounded = safeValue.round();
    return '₹${_formatWithCommas(rounded)}';
  }

  static String _formatWithCommas(int value) {
    final input = value.toString();
    if (input.length <= 3) return input;
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final indexFromEnd = input.length - i;
      buffer.write(input[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  static const String placeholderImage =
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=1000&q=80';

  factory StockProduct.fromSupabase(Map<String, dynamic> row) {
    double? parseSalePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return StockProduct(
      stockId: ((row['stock_id'] ?? row['stockid']) as num?)?.toInt() ?? 0,
      productName: ((row['product_name'] ?? '').toString()).trim().isEmpty
          ? 'Refurbished Laptop'
          : (row['product_name'] ?? '').toString(),
      productConfig: ((row['product_config'] ?? '').toString()).trim().isEmpty
          ? 'Configuration details available on request'
          : (row['product_config'] ?? '').toString(),
      productImage: ((row['product_image'] ?? '').toString()).trim().isEmpty
          ? placeholderImage
          : (row['product_image'] ?? '').toString(),
      condition: ((row['condition'] ?? '').toString()).trim().isEmpty
          ? 'Refurbished'
          : (row['condition'] ?? '').toString(),
      salePrice: parseSalePrice(row['saleprice']),
      productId: (row['productid'] as num?)?.toInt(),
      businessId: (row['business_id'] as num?)?.toInt(),
      vendorId: (row['vendor_id'] as num?)?.toInt(),
      vendorName: row['vendor_name']?.toString(),
      isSold: row['isSold'] as bool?,
    );
  }
}
