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

    if (json['product'] != null) {
      name = json['product']['name'] ?? name;
      price = double.tryParse(json['product']['discount_price']?.toString() ?? json['product']['price']?.toString() ?? '0.0') ?? 0.0;
      if (json['product']['primary_image'] != null && json['product']['primary_image']['image_url'] != null) {
        img = json['product']['primary_image']['image_url'];
      }
    } else {
      name = json['name'] ?? name;
      price = double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
      img = json['image_url'];
    }

    return CartItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id'].toString()) ?? 0,
      productName: name,
      variant: json['variant'] ?? 'Standard',
      unitPrice: price,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      imageUrl: img,
      inStock: true,
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
      cartItems = (json['items'] as List).map((i) => CartItemModel.fromJson(i)).toList();
    }

    final double sub = double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0;
    final double disc = double.tryParse(json['discount']?.toString() ?? '0.0') ?? 0.0;
    final double ship = double.tryParse(json['shipping']?.toString() ?? '10.0') ?? 10.0;
    final double tx = double.tryParse(json['tax']?.toString() ?? '0.0') ?? 0.0;
    final double tot = double.tryParse(json['total']?.toString() ?? (sub - disc + ship + tx).toString()) ?? 0.0;

    return CartModel(
      items: cartItems,
      subtotal: sub,
      discount: disc,
      shipping: ship,
      tax: tx,
      total: tot,
      couponCode: json['coupon'] != null ? json['coupon']['code'] : null,
    );
  }
}
