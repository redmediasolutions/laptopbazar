import 'package:supabase/supabase.dart';
import 'package:electralap/models/stock_product.dart';

class SupabaseService {
  static const int businessIdFilter = 5;
  static const String supabaseUrl = 'https://gdxepzlxzlzjrkxqpqwo.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkeGVwemx4emx6anJreHFwcXdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4ODU0NjMsImV4cCI6MjA2NzQ2MTQ2M30.--UZamnWbyCmxZ6GC-An8aw_mwzZ-SMpNTANSf-kWWM';

  static final SupabaseClient client = SupabaseClient(supabaseUrl, supabaseAnonKey);

  static Future<List<StockProduct>> fetchProducts() async {
    final response = await client
        .from('allstockv2')
        .select('stock_id, business_id, product_name, product_config, product_image, condition, saleprice, isSold')
        .eq('business_id', businessIdFilter)
        .order('stock_id');

    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(StockProduct.fromSupabase).toList(growable: false);
  }

  static Future<StockProduct?> fetchProductByStockId(int stockId) async {
    final response = await client
        .from('allstockv2')
        .select('stock_id, business_id, product_name, product_config, product_image, condition, saleprice, isSold')
        .eq('business_id', businessIdFilter)
        .eq('stock_id', stockId)
        .limit(1);

    final rows = (response as List).cast<Map<String, dynamic>>();
    if (rows.isEmpty) return null;
    return StockProduct.fromSupabase(rows.first);
  }

  static Future<List<StockProduct>> fetchProductsByStockIds(List<int> stockIds) async {
    if (stockIds.isEmpty) return const [];

    final response = await client
        .from('allstockv2')
        .select('stock_id, business_id, product_name, product_config, product_image, condition, saleprice, isSold')
        .eq('business_id', businessIdFilter)
        .inFilter('stock_id', stockIds);

    final rows = (response as List).cast<Map<String, dynamic>>();
    final products = rows.map(StockProduct.fromSupabase).toList(growable: false);
    final byId = {for (final p in products) p.stockId: p};

    return stockIds.map((id) => byId[id]).whereType<StockProduct>().toList(growable: false);
  }
}
