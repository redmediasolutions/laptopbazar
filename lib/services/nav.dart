import 'package:electralap/pages/about.dart';
import 'package:electralap/pages/cart.dart';
import 'package:electralap/pages/checkout.dart';
import 'package:electralap/pages/contact.dart';
import 'package:electralap/pages/home_page.dart';
import 'package:electralap/pages/profile.dart';
import 'package:electralap/pages/products.dart';
import 'package:electralap/pages/productdetail.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class NavPaths {
  static const home = '/';
  static const products = '/products';
  static const cart = '/cart';
  static const productDetail = '/productdetail/:stockId';
  static const about = '/about';
  static const profile = '/profile';
  static const checkout = '/checkout';
  static const contact = '/contact';

  static String productDetailById(int stockId) => '/productdetail/$stockId';
}

class Webnav {
  static int? _parsePositiveInt(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static Component router() {
    return Router(
      routes: [
        Route(path: NavPaths.home,
         builder: (context,
          state) => const HomePage()),

        Route(path: NavPaths.products,
         builder: (context,
          state) => ProductsPage(
            selectedBrand: state.queryParams['brand'],
            selectedCondition: state.queryParams['condition'],
            selectedPage: state.queryParams['page'],
            searchQuery: state.queryParams['q'],
          )),

        Route(path: NavPaths.cart,
         builder: (context,
             state) => CartPage(
              stockId: _parsePositiveInt(state.queryParams['stockId']),
             )),

        Route(path: NavPaths.productDetail,
         builder: (context,
          state) => ProductDetailPage(
            stockId: int.tryParse(state.params['stockId'] ?? ''),
          )),

        Route(path: NavPaths.about,
         builder: (context,
          state) => const About()),

        Route(path: NavPaths.profile,
         builder: (context,
          state) => const ProfilePage()),
          
        Route(path: NavPaths.checkout,
         builder: (context,
          state) => const CheckoutPage()),

        Route(path: NavPaths.contact,
         builder: (context,
          state) => const ContactPage()),
      ],
      errorBuilder: (context,
       state) => const HomePage(),
    );
  }
}
