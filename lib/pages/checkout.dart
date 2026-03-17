// ignore_for_file: deprecated_member_use

import 'package:electralap/components/footer.dart';
import 'package:electralap/components/header.dart';
import 'package:electralap/models/stock_product.dart';
import 'package:electralap/services/cart_store.dart';
import 'package:electralap/services/nav.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:universal_web/web.dart' as web;

class CheckoutPage extends StatelessComponent {
  const CheckoutPage({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'page', [
      const AppHeader(),
      main_([
        section(classes: 'checkout-main', [
          div(classes: 'container', [
            h1(classes: 'checkout-title', [text('Secure Checkout')]),
            p(classes: 'checkout-subtitle', [text('Complete your order in just a few steps')]),
            const CheckoutScreen(),
          ]),
        ]),
      ]),
      const AppFooter(),
    ]);
  }
}

@client
class CheckoutScreen extends StatefulComponent {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const String _whatsAppNumber = '918867735897';

  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _gst = '';
  String _address1 = '';
  String _address2 = '';
  String _city = '';
  String _state = '';
  String _pincode = '';

  List<CartItemData> _items = const [];
  bool _isSubmitting = false;
  bool _showSuccess = false;
  String? _submitError;
  final Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      CartStore.ensureLastFallback();
    }
    _items = CartStore.getItemsList();
  }

  double get _grandTotal {
    var total = 0.0;
    for (final item in _items) {
      final price = item.salePrice ?? 0;
      total += price * item.qty;
    }
    return total;
  }

  void _setField(String key, String value) {
    setState(() {
      switch (key) {
        case 'fullName':
          _fullName = value;
          break;
        case 'email':
          _email = value;
          break;
        case 'phone':
          _phone = value;
          break;
        case 'gst':
          _gst = value;
          break;
        case 'address1':
          _address1 = value;
          break;
        case 'address2':
          _address2 = value;
          break;
        case 'city':
          _city = value;
          break;
        case 'state':
          _state = value;
          break;
        case 'pincode':
          _pincode = value;
          break;
      }
      _errors.remove(key);
      _submitError = null;
    });
  }

  String _inputClass(String key) {
    return _errors.containsKey(key) ? 'checkout-input input-error' : 'checkout-input';
  }

  bool _validate() {
    final nextErrors = <String, String>{};

    if (_fullName.trim().isEmpty) nextErrors['fullName'] = 'Full name is required.';
    if (_email.trim().isEmpty) {
      nextErrors['email'] = 'Email is required.';
    } else if (!_email.contains('@')) {
      nextErrors['email'] = 'Enter a valid email.';
    }
    if (_phone.trim().isEmpty) {
      nextErrors['phone'] = 'Phone number is required.';
    } else if (_phone.replaceAll(RegExp(r'\D'), '').length < 10) {
      nextErrors['phone'] = 'Enter a valid phone number.';
    }
    if (_address1.trim().isEmpty) nextErrors['address1'] = 'Address Line 1 is required.';
    if (_city.trim().isEmpty) nextErrors['city'] = 'City is required.';
    if (_state.trim().isEmpty) nextErrors['state'] = 'State is required.';
    if (_pincode.trim().isEmpty) {
      nextErrors['pincode'] = 'Pincode is required.';
    } else if (_pincode.replaceAll(RegExp(r'\D'), '').length < 5) {
      nextErrors['pincode'] = 'Enter a valid pincode.';
    }

    if (_items.isEmpty) {
      nextErrors['cart'] = 'Your cart is empty.';
    }

    if (nextErrors.isEmpty) return true;
    setState(() {
      _errors
        ..clear()
        ..addAll(nextErrors);
    });
    return false;
  }

  String _buildWhatsAppMessage() {
    final lines = <String>[
      'New Order - ELECTRALAP',
      '',
      'Contact Information',
      'Name: ${_fullName.trim()}',
      'Email: ${_email.trim()}',
      'Phone: ${_phone.trim()}',
      'GST: ${_gst.trim().isEmpty ? '-' : _gst.trim()}',
      '',
      'Shipping Address',
      'Address Line 1: ${_address1.trim()}',
      if (_address2.trim().isNotEmpty) 'Address Line 2: ${_address2.trim()}',
      'City: ${_city.trim()}',
      'State: ${_state.trim()}',
      'Pincode: ${_pincode.trim()}',
      'Country: India',
      '',
      'Items',
    ];

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final unitPrice = item.salePrice ?? 0;
      final lineTotal = unitPrice * item.qty;
      lines.add('${i + 1}. ${item.name}');
      if (item.config.trim().isNotEmpty) {
        lines.add('   Config: ${item.config.trim()}');
      }
      lines.add('   Condition: ${item.condition}');
      lines.add('   Qty: ${item.qty}');
      lines.add('   Unit Price: ${StockProduct.formatPrice(unitPrice)}');
      lines.add('   Line Total: ${StockProduct.formatPrice(lineTotal)}');
    }

    lines.add('');
    lines.add('Grand Total: ${StockProduct.formatPrice(_grandTotal)}');
    return lines.join('\n');
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;
    if (!_validate()) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      if (!kIsWeb) {
        setState(() {
          _submitError = 'WhatsApp ordering is only available in the web app.';
        });
        return;
      }

      final message = _buildWhatsAppMessage();
      final encoded = Uri.encodeComponent(message);
      final url = 'https://wa.me/$_whatsAppNumber?text=$encoded';
      web.window.open(url, '_blank');

      setState(() {
        _showSuccess = true;
        _items = const [];
      });
      CartStore.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Component _field(String key, Component input) {
    final error = _errors[key];
    return div(classes: 'field-group', [
      input,
      if (error != null) span(classes: 'field-error', [text(error)]),
    ]);
  }

  Component _miniItem(CartItemData item) {
    final price = (item.salePrice ?? 0) * item.qty;
    return div(classes: 'checkout-mini-item', [
      div([
        h4([text(item.name)]),
        p([text('Qty ${item.qty}')]),
      ]),
      span([text(StockProduct.formatPrice(price))]),
    ]);
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'checkout-layout', [
      div(classes: 'checkout-forms', [
        div(classes: 'checkout-card', [
          h2([text('Contact Information')]),
          div(classes: 'checkout-grid two', [
            _field(
              'fullName',
              input(
                classes: _inputClass('fullName'),
                value: _fullName,
                onInput: (value) => _setField('fullName', '$value'),
                attributes: {'placeholder': 'Full Name'},
              ),
            ),
            _field(
              'email',
              input(
                classes: _inputClass('email'),
                value: _email,
                onInput: (value) => _setField('email', '$value'),
                type: InputType.email,
                attributes: {'placeholder': 'Email Address'},
              ),
            ),
            _field(
              'phone',
              input(
                classes: _inputClass('phone'),
                value: _phone,
                onInput: (value) => _setField('phone', '$value'),
                type: InputType.tel,
                attributes: {'placeholder': 'Phone Number'},
              ),
            ),
            _field(
              'gst',
              input(
                classes: 'checkout-input',
                value: _gst,
                onInput: (value) => _setField('gst', '$value'),
                attributes: {'placeholder': 'GST Number (Optional)'},
              ),
            ),
          ]),
        ]),
        div(classes: 'checkout-card', [
          h2([text('Shipping Address')]),
          div(classes: 'checkout-grid two', [
            _field(
              'address1',
              input(
                classes: _inputClass('address1'),
                value: _address1,
                onInput: (value) => _setField('address1', '$value'),
                attributes: {'placeholder': 'Address Line 1'},
              ),
            ),
            _field(
              'address2',
              input(
                classes: 'checkout-input',
                value: _address2,
                onInput: (value) => _setField('address2', '$value'),
                attributes: {'placeholder': 'Address Line 2'},
              ),
            ),
            _field(
              'city',
              input(
                classes: _inputClass('city'),
                value: _city,
                onInput: (value) => _setField('city', '$value'),
                attributes: {'placeholder': 'City'},
              ),
            ),
            _field(
              'state',
              input(
                classes: _inputClass('state'),
                value: _state,
                onInput: (value) => _setField('state', '$value'),
                attributes: {'placeholder': 'State'},
              ),
            ),
            _field(
              'pincode',
              input(
                classes: _inputClass('pincode'),
                value: _pincode,
                onInput: (value) => _setField('pincode', '$value'),
                attributes: {'placeholder': 'Pincode'},
              ),
            ),
            div(classes: 'checkout-select', [
              span([text('India')]),
              span(classes: 'material-symbols-outlined', [text('expand_more')]),
            ]),
          ]),
        ]),
      ]),
      div(classes: 'checkout-summary', [
        h2([text('Order Summary')]),
        if (_items.isEmpty)
          div(classes: 'products-empty', [
            text('Your cart is empty. Add products before checkout.'),
          ])
        else
          div(classes: 'checkout-items', [
            ..._items.map(_miniItem),
          ]),
        if (_errors['cart'] != null)
          span(classes: 'field-error', [text(_errors['cart']!)]),
        div(classes: 'summary-total', [
          span([text('Grand Total')]),
          span([text(StockProduct.formatPrice(_grandTotal))]),
        ]),
        if (_submitError != null) span(classes: 'field-error', [text(_submitError!)]),
        button(
          classes: _isSubmitting ? 'checkout-btn disabled' : 'checkout-btn',
          disabled: _isSubmitting,
          onClick: _placeOrder,
          [
            text(_isSubmitting ? 'Placing Order...' : 'Place Order'),
            span(classes: 'material-symbols-outlined', [text('lock')]),
          ],
        ),
        Link(to: NavPaths.cart, classes: 'continue-btn', children: [
          span(classes: 'material-symbols-outlined', [text('arrow_back')]),
          text('Back to Cart'),
        ]),
      ]),
      if (_showSuccess)
        div(classes: 'order-popup-overlay', [
          div(classes: 'order-popup', [
            h3([text('WhatsApp opened!')]),
            p([
              text('Your order details are ready in WhatsApp. Please tap Send to confirm.'),
            ]),
            button(
              classes: 'checkout-btn',
              onClick: () {
                setState(() {
                  _showSuccess = false;
                });
                Router.of(context).push(NavPaths.home);
              },
              [text('Back to Home')],
            ),
          ]),
        ]),
    ]);
  }
}

