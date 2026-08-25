class CartItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? variant;
  final double unitPrice;
  int quantity;
  final String? imageUrl;
  final bool inStock;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.variant,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl,
    this.inStock = true,
  });

  double get totalPrice => unitPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    String? img;
    String name = 'Product';
    double price = 0.0;
    int stockQty = 10;

    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      final p = json['product'] as Map<String, dynamic>;
      name = p['name'] ?? name;
      price = double.tryParse(p['discount_price']?.toString() ?? p['price']?.toString() ?? '0.0') ?? 0.0;
      stockQty = p['stock'] is int ? p['stock'] : int.tryParse(p['stock']?.toString() ?? '10') ?? 10;
      
      if (p['primary_image'] != null && p['primary_image']['image_url'] != null) {
        img = p['primary_image']['image_url'];
      } else if (p['images'] is List && (p['images'] as List).isNotEmpty) {
        img = p['images'][0]['image_url'];
      } else if (p['image_url'] != null) {
        img = p['image_url'];
      }
    } else {
      name = json['name'] ?? json['product_name'] ?? name;
      price = double.tryParse(json['unit_price']?.toString() ?? json['price']?.toString() ?? '0.0') ?? 0.0;
      img = json['image_url'];
    }

    if (price == 0.0 && json['unit_price'] != null) {
      price = double.tryParse(json['unit_price'].toString()) ?? 0.0;
    }

    return CartItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: name,
      variant: json['variant'] ?? (name.contains('MacBook') ? 'Space Gray, 512GB SSD' : (name.contains('AirPods') ? 'White' : 'Standard')),
      unitPrice: price,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      imageUrl: img ?? 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300&auto=format&fit=crop&q=80',
      inStock: stockQty > 0,
    );
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final String? couponCode;

  CartModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    this.couponCode,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    List<CartItemModel> cartItems = [];
    if (json['items'] is List) {
      cartItems = (json['items'] as List).map((i) => CartItemModel.fromJson(i as Map<String, dynamic>)).toList();
    }

    final calc = json['calculation'] is Map<String, dynamic> ? json['calculation'] as Map<String, dynamic> : null;

    final double sub = double.tryParse(calc?['subtotal']?.toString() ?? json['subtotal']?.toString() ?? '0.0') ??
        cartItems.fold(0.0, (sum, i) => sum + i.totalPrice);
        
    final double disc = double.tryParse(calc?['discount']?.toString() ?? json['discount']?.toString() ?? '0.0') ?? 0.0;
    final double ship = double.tryParse(calc?['shipping']?.toString() ?? json['shipping']?.toString() ?? (sub >= 2000.0 || sub == 0 ? '0.0' : '10.0')) ?? 10.0;
    final double tx = double.tryParse(calc?['tax']?.toString() ?? json['tax']?.toString() ?? (sub * 0.10).toString()) ?? 0.0;
    final double tot = double.tryParse(calc?['grand_total']?.toString() ?? json['total']?.toString() ?? (sub - disc + ship + tx).toString()) ?? (sub - disc + ship + tx);

    String? coup;
    if (json['coupon'] != null && json['coupon'] is Map<String, dynamic>) {
      coup = json['coupon']['code'];
    } else if (json['coupon_code'] != null) {
      coup = json['coupon_code'].toString();
    }

    return CartModel(
      items: cartItems,
      subtotal: sub,
      discount: disc,
      shipping: ship,
      tax: tx,
      total: tot,
      couponCode: coup,
    );
  }
}
