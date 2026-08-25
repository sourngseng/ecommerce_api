import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  final http.Client _client = http.Client();

  Map<String, String> _getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // 1. Login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'Flutter Mobile App',
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Login successful',
          data: body['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Invalid email or password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e\nEnsure the backend server is running.',
        statusCode: 500,
      );
    }
  }

  // 2. Register
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String role = 'customer',
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}');
      final response = await _client.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'role': role,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Registration successful',
          data: body['data'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Validation error during registration',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  // 3. Get Current User (/auth/me)
  Future<ApiResponse<UserModel>> getCurrentUser(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meEndpoint}');
      final response = await _client.get(
        url,
        headers: _getHeaders(token),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return ApiResponse(
          success: true,
          message: body['message'] ?? 'Profile retrieved',
          data: UserModel.fromJson(body['data']['user']),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: body['message'] ?? 'Session expired',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection error: $e',
        statusCode: 500,
      );
    }
  }

  // 4. Logout
  Future<void> logout(String token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}');
      await _client.post(
        url,
        headers: _getHeaders(token),
      );
    } catch (_) {}
  }

  // 5. Get General System Settings
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.settingsEndpoint}');
      final response = await _client.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] ?? {};
        }
      }
    } catch (_) {}
    return {};
  }

  // 6. Get Banners
  Future<List<BannerModel>> getBanners() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bannersEndpoint}?position=slider');
      final response = await _client.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List).map((b) => BannerModel.fromJson(b)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  // 7. Get Categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}');
      final response = await _client.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List).map((c) => CategoryModel.fromJson(c)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  // 8. Get Products with dynamic filtering & sorting
  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    String? sortBy,
    String? sortOrder,
    double? minPrice,
    double? maxPrice,
    bool? featured,
    int perPage = 20,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}');
      final queryParams = <String, String>{
        'per_page': perPage.toString(),
      };

      if (categoryId != null && categoryId > 0) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sort_by'] = sortBy;
      }
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams['sort_order'] = sortOrder;
      }
      if (minPrice != null && minPrice > 0) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null && maxPrice > 0) {
        queryParams['max_price'] = maxPrice.toString();
      }
      if (featured == true) {
        queryParams['featured'] = '1';
      }

      final url = uri.replace(queryParameters: queryParams);
      final response = await _client.get(url, headers: _getHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List).map((p) => ProductModel.fromJson(p)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  // 9. Get Flash Sale Products
  Future<List<ProductModel>> getFlashSaleProducts() async {
    return getProducts(featured: true, perPage: 6);
  }

  // 10. Get New Arrivals
  Future<List<ProductModel>> getNewArrivals() async {
    return getProducts(sortBy: 'created_at', sortOrder: 'desc', perPage: 8);
  }

  // 11. Get Single Product Details
  Future<ProductModel?> getProductDetails(int id) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}/$id');
      final response = await _client.get(url, headers: _getHeaders());
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return ProductModel.fromJson(body['data']);
        }
      }
    } catch (_) {}
    return null;
  }

  // 12. Add to Cart
  Future<bool> addToCart(String? token, int productId, int quantity) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/items');
      final response = await _client.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'product_id': productId,
          'quantity': quantity,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 13. Get Cart Details
  Future<Map<String, dynamic>?> getCart(String? token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await _client.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return body['data'];
        }
      }
    } catch (_) {}
    return null;
  }

  // 14. Update Cart Item Quantity
  Future<bool> updateCartItemQuantity(String? token, int itemId, int quantity) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/items/$itemId');
      final response = await _client.put(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'quantity': quantity,
        }),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 15. Remove Cart Item
  Future<bool> removeCartItem(String? token, int itemId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/items/$itemId');
      final response = await _client.delete(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 16. Clear Entire Cart
  Future<bool> clearCart(String? token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/clear');
      final response = await _client.delete(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 17. Apply Coupon Code
  Future<ApiResponse<Map<String, dynamic>>> applyCoupon(String? token, String code) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/apply-coupon');
      final response = await _client.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'code': code,
        }),
      );
      final Map<String, dynamic> body = jsonDecode(response.body);
      return ApiResponse(
        success: response.statusCode == 200 && body['success'] == true,
        message: body['message'] ?? (response.statusCode == 200 ? 'Coupon applied' : 'Invalid coupon'),
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error applying coupon: $e',
        statusCode: 500,
      );
    }
  }

  // 18. Remove Coupon
  Future<bool> removeCoupon(String? token) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/coupon');
      final response = await _client.delete(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 19. Place Order / Checkout
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String? token,
    required Map<String, dynamic> shippingAddress,
    required String shippingMethod,
    required String paymentMethod,
    String? couponCode,
    String? notes,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders');
      final response = await _client.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'shipping_address': shippingAddress,
          'shipping_method': shippingMethod,
          'payment_method': paymentMethod,
          'coupon_code': couponCode,
          'notes': notes,
          if (items != null && items.isNotEmpty) 'items': items,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      return ApiResponse(
        success: (response.statusCode == 200 || response.statusCode == 201) && body['success'] == true,
        message: body['message'] ?? (response.statusCode == 201 ? 'Order placed successfully!' : 'Order failed'),
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Checkout error: $e',
        statusCode: 500,
      );
    }
  }

  // 20. Get User Orders
  Future<List<Map<String, dynamic>>> getMyOrders(String? token, {String? status}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/orders');
      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty && status != 'all') {
        queryParams['status'] = status;
      }
      final url = uri.replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      final response = await _client.get(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  // 21. Cancel Order
  Future<bool> cancelOrder(String? token, int orderId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders/$orderId/cancel');
      final response = await _client.post(url, headers: _getHeaders(token));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  // 22. Submit Product Review & Rating
  Future<ApiResponse<Map<String, dynamic>>> submitProductReview({
    required String? token,
    required int productId,
    required int rating,
    String? comment,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/products/$productId/reviews');
      final response = await _client.post(
        url,
        headers: _getHeaders(token),
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      final Map<String, dynamic> body = jsonDecode(response.body);

      return ApiResponse(
        success: (response.statusCode == 200 || response.statusCode == 201) && body['success'] == true,
        message: body['message'] ?? (response.statusCode == 201 ? 'Review submitted successfully!' : 'Failed to submit review'),
        data: body['data'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Review submission error: $e',
        statusCode: 500,
      );
    }
  }
}
