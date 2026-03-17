import 'package:electralap/models/stock_product.dart';

const List<Map<String, dynamic>> _stockRows = [
  {
    'stock_id': 1,
    'product_name': 'MacBook Pro 14" M1',
    'product_config': '16GB RAM - 512GB SSD',
    'product_image':
        'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8YXBwZSUyMGxhcHRvcHxlbnwwfHwwfHx8MA%3D%3D',
    'condition': 'Excellent',
    'saleprice': 129900,
  },
  {
    'stock_id': 2,
    'product_name': 'Dell XPS 15',
    'product_config': '32GB RAM - 1TB SSD',
    'product_image':
        'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?auto=format&fit=crop&w=1000&q=80',
    'condition': 'Very Good',
    'saleprice': 89900,
  },
  {
    'stock_id': 3,
    'product_name': 'ThinkPad X1 Carbon',
    'product_config': '16GB RAM - 256GB SSD',
    'product_image':
        'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?auto=format&fit=crop&w=1000&q=80',
    'condition': 'Good',
    'saleprice': 79900,
  },
  {
    'stock_id': 4,
    'product_name': 'HP EliteBook 840',
    'product_config': '16GB RAM - 512GB SSD',
    'product_image':
        'https://images.unsplash.com/photo-1484788984921-03950022c9ef?auto=format&fit=crop&w=1000&q=80',
    'condition': 'Very Good',
    'saleprice': 64900,
  },
  {
    'stock_id': 5,
    'product_name': 'ASUS ROG Zephyrus',
    'product_config': '16GB RAM - 1TB SSD - RTX 3060',
    'product_image':
        'https://images.unsplash.com/photo-1603302576837-37561b2e2302?auto=format&fit=crop&w=1000&q=80',
    'condition': 'Excellent',
    'saleprice': 109900,
  },
  {
    'stock_id': 6,
    'product_name': 'Surface Laptop 5',
    'product_config': '16GB RAM - 256GB SSD',
    'product_image':
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=1000&q=80',
    'condition': 'Excellent',
    'saleprice': 84900,
  },
];

final List<StockProduct> stockProducts =
    _stockRows.map(StockProduct.fromSupabase).toList(growable: false);

const Map<int, String> stockDiscountById = {
  1: '35% OFF',
  2: '40% OFF',
  3: '43% OFF',
  4: '46% OFF',
  5: '39% OFF',
  6: '35% OFF',
};

const Map<int, String> stockRatingById = {
  1: '4.9',
  2: '4.8',
  3: '4.7',
  4: '4.6',
  5: '4.8',
  6: '4.7',
};
