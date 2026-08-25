import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CartItemModel> get items => _cart?.items ?? [];
  int get itemCount => _cart?.totalItemCount ?? 0;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get discount => _cart?.discount ?? 0.0;
  double get shipping => _cart?.shipping ?? 0.0;
  double get tax => _cart?.tax ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  String? get couponCode => _cart?.couponCode;

  // 1. Fetch live cart from backend API
  Future<void> fetchCart(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cartData = await _apiService.getCart(token);
      if (cartData != null) {
        _cart = CartModel.fromJson(cartData);
      } else {
        // If no cart on backend yet or guest mode, keep current or seed
        _cart ??= _getInitialFallbackCart();
      }
    } catch (e) {
      _errorMessage = 'Failed to load cart: $e';
      _cart ??= _getInitialFallbackCart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Add product to cart via API
  Future<bool> addToCart(String? token, int productId, int quantity, {Map<String, dynamic>? productFallback}) async {
    bool success = await _apiService.addToCart(token, productId, quantity);

    if (token != null && token.isNotEmpty) {
      // Re-fetch latest cart from API
      await fetchCart(token);
    } else {
      // Offline / guest mode local addition
      _addItemLocally(productId, quantity, productFallback);
      notifyListeners();
    }

    return success;
  }

  // 3. Update quantity of item in cart
  Future<bool> updateQuantity(String? token, int itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      return removeItem(token, itemId);
    }

    // Optimistic local update
    final itemIndex = items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      items[itemIndex].quantity = newQuantity;
      _recalculateTotals();
      notifyListeners();
    }

    bool success = await _apiService.updateCartItemQuantity(token, itemId, newQuantity);
    if (token != null && token.isNotEmpty) {
      final cartData = await _apiService.getCart(token);
      if (cartData != null) {
        _cart = CartModel.fromJson(cartData);
        notifyListeners();
      }
    }
    return success;
  }

  // 4. Remove item from cart
  Future<bool> removeItem(String? token, int itemId) async {
    // Optimistic removal
    items.removeWhere((i) => i.id == itemId);
    _recalculateTotals();
    notifyListeners();

    bool success = await _apiService.removeCartItem(token, itemId);
    if (token != null && token.isNotEmpty) {
      final cartData = await _apiService.getCart(token);
      if (cartData != null) {
        _cart = CartModel.fromJson(cartData);
        notifyListeners();
      }
    }
    return success;
  }

  // 5. Restore item (Undo)
  void restoreItem(CartItemModel item, int index) {
    if (index >= 0 && index <= items.length) {
      items.insert(index, item);
    } else {
      items.add(item);
    }
    _recalculateTotals();
    notifyListeners();
  }

  // 6. Apply coupon code via API
  Future<ApiResponse<Map<String, dynamic>>> applyCoupon(String? token, String code) async {
    final res = await _apiService.applyCoupon(token, code);
    if (res.success && res.data != null) {
      _cart = CartModel.fromJson(res.data!);
    } else {
      // Local demo discount
      _cart = CartModel(
        items: items,
        subtotal: subtotal,
        discount: 100.00,
        shipping: shipping,
        tax: tax,
        total: (subtotal - 100.00 + shipping + tax).clamp(0.0, double.infinity),
        couponCode: code.toUpperCase(),
      );
    }
    notifyListeners();
    return res;
  }

  // 7. Remove coupon
  Future<void> removeCoupon(String? token) async {
    await _apiService.removeCoupon(token);
    _recalculateTotals(clearCoupon: true);
    notifyListeners();
  }

  // 8. Clear entire cart
  Future<void> clearCart(String? token) async {
    await _apiService.clearCart(token);
    _cart = CartModel(
      items: [],
      subtotal: 0.0,
      discount: 0.0,
      shipping: 0.0,
      tax: 0.0,
      total: 0.0,
    );
    notifyListeners();
  }

  void _recalculateTotals({bool clearCoupon = false}) {
    final double sub = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final String? coup = clearCoupon ? null : couponCode;
    final double disc = coup != null ? (sub * 0.10).clamp(0.0, 100.0) : 0.0;
    final double ship = sub >= 2000.0 || sub == 0 ? 0.0 : 10.0;
    final double tx = sub * 0.10;
    final double tot = (sub - disc + ship + tx).clamp(0.0, double.infinity);

    _cart = CartModel(
      items: items,
      subtotal: sub,
      discount: disc,
      shipping: ship,
      tax: tx,
      total: tot,
      couponCode: coup,
    );
  }

  void _addItemLocally(int productId, int quantity, Map<String, dynamic>? productFallback) {
    final existingIndex = items.indexWhere((i) => i.productId == productId);
    if (existingIndex != -1) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(
        CartItemModel(
          id: DateTime.now().millisecondsSinceEpoch,
          productId: productId,
          productName: productFallback?['name'] ?? 'Product #$productId',
          variant: productFallback?['variant'] ?? 'Space Gray, 512GB SSD',
          unitPrice: productFallback?['price'] ?? 1299.00,
          quantity: quantity,
          imageUrl: productFallback?['image_url'] ?? 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
          inStock: true,
        ),
      );
    }
    _recalculateTotals();
  }

  CartModel _getInitialFallbackCart() {
    final initialItems = [
      CartItemModel(
        id: 1,
        productId: 101,
        productName: 'MacBook Pro 14-inch (2023)',
        variant: 'Space Gray, 512GB SSD',
        unitPrice: 1299.00,
        quantity: 1,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
        inStock: true,
      ),
      CartItemModel(
        id: 2,
        productId: 102,
        productName: 'Apple AirPods Pro 2',
        variant: 'White',
        unitPrice: 249.00,
        quantity: 2,
        imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&auto=format&fit=crop&q=80',
        inStock: true,
      ),
      CartItemModel(
        id: 3,
        productId: 103,
        productName: 'Travel Backpack Premium',
        variant: 'Black',
        unitPrice: 44.99,
        quantity: 1,
        imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&auto=format&fit=crop&q=80',
        inStock: true,
      ),
    ];

    return CartModel(
      items: initialItems,
      subtotal: 1841.99,
      discount: 100.00,
      shipping: 10.00,
      tax: 175.20,
      total: 1927.19,
      couponCode: 'WELCOME10',
    );
  }
}
