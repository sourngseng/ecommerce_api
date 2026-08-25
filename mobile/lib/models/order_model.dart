class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final String? imageUrl;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String? img;
    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      final p = json['product'] as Map<String, dynamic>;
      if (p['primary_image'] != null && p['primary_image']['image_url'] != null) {
        img = p['primary_image']['image_url'];
      } else if (p['images'] is List && (p['images'] as List).isNotEmpty) {
        img = p['images'][0]['image_url'];
      } else if (p['image_url'] != null) {
        img = p['image_url'];
      }
    } else if (json['image_url'] != null) {
      img = json['image_url'];
    }

    return OrderItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name'] ?? json['product']?['name'] ?? 'Product',
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0.0') ?? 0.0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: img,
    );
  }
}

class OrderModel {
  final int id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final String statusSubtitle;
  final String statusDesc;
  final double subtotal;
  final double discount;
  final double tax;
  final double shipping;
  final double total;
  final String createdAt;
  final List<OrderItemModel> items;
  final List<String> thumbnails;
  final int extraCount;
  final Map<String, dynamic>? shippingAddress;
  final String? notes;
  final bool canBeCancelled;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.statusSubtitle,
    required this.statusDesc,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.createdAt,
    required this.items,
    required this.thumbnails,
    required this.extraCount,
    this.shippingAddress,
    this.notes,
    this.canBeCancelled = false,
  });

  int get itemsCount => items.isNotEmpty ? items.fold(0, (sum, i) => sum + i.quantity) : 1;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();

    String label = 'Pending';
    String subtitle = 'Processing';
    String desc = 'We are preparing your order.';

    if (rawStatus == 'delivered') {
      label = 'Delivered';
      subtitle = 'Delivered on May 15, 2024';
      desc = 'Your order has been delivered successfully.';
    } else if (rawStatus == 'shipped') {
      label = 'Shipped';
      subtitle = 'In Transit';
      desc = 'Estimated delivery in 2-3 business days.';
    } else if (rawStatus == 'processing' || rawStatus == 'confirmed') {
      label = 'Processing';
      subtitle = 'Processing';
      desc = 'We are packing and preparing your package.';
    } else if (rawStatus == 'cancelled') {
      label = 'Cancelled';
      subtitle = 'Cancelled';
      desc = 'This order has been cancelled.';
    } else if (rawStatus == 'pending' || rawStatus == 'unpaid' || rawStatus == 'to_pay') {
      label = 'To Pay';
      subtitle = 'Payment Pending';
      desc = 'Awaiting payment confirmation.';
    }

    List<OrderItemModel> orderItems = [];
    List<String> thumbs = [];

    if (json['items'] is List) {
      for (var itemJson in json['items'] as List) {
        final item = OrderItemModel.fromJson(itemJson as Map<String, dynamic>);
        orderItems.add(item);
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
          thumbs.add(item.imageUrl!);
        }
      }
    }

    if (thumbs.isEmpty && json['thumbnails'] is List) {
      thumbs = List<String>.from(json['thumbnails']);
    }

    // Default thumbnails if product has none
    if (thumbs.isEmpty) {
      if (rawStatus == 'delivered') {
        thumbs = [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=200&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=200&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=200&auto=format&fit=crop&q=80',
        ];
      } else if (rawStatus == 'shipped') {
        thumbs = [
          'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=200&auto=format&fit=crop&q=80',
        ];
      } else if (rawStatus == 'processing') {
        thumbs = [
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&auto=format&fit=crop&q=80',
        ];
      }
    }

    final int visibleCount = thumbs.length > 3 ? 3 : thumbs.length;
    final List<String> displayThumbs = thumbs.take(visibleCount).toList();
    final int extra = thumbs.length > 3 ? thumbs.length - 3 : 0;

    String dateStr = json['created_at']?.toString() ?? 'May 12, 2024 at 10:30 AM';
    try {
      final parsedDate = DateTime.tryParse(dateStr);
      if (parsedDate != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final m = months[parsedDate.month - 1];
        final d = parsedDate.day.toString().padLeft(2, '0');
        final y = parsedDate.year;
        final hour = parsedDate.hour > 12 ? parsedDate.hour - 12 : (parsedDate.hour == 0 ? 12 : parsedDate.hour);
        final ampm = parsedDate.hour >= 12 ? 'PM' : 'AM';
        final minute = parsedDate.minute.toString().padLeft(2, '0');
        dateStr = '$m $d, $y at ${hour.toString().padLeft(2, '0')}:$minute $ampm';
      }
    } catch (_) {}

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: json['order_number'] ?? 'ORD-2024-${(json['id'] ?? '100').toString().padLeft(6, '0')}',
      status: rawStatus,
      statusLabel: label,
      statusSubtitle: subtitle,
      statusDesc: desc,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0.0') ?? 0.0,
      discount: double.tryParse(json['discount_amount']?.toString() ?? json['discount']?.toString() ?? '0.0') ?? 0.0,
      tax: double.tryParse(json['tax_amount']?.toString() ?? json['tax']?.toString() ?? '0.0') ?? 0.0,
      shipping: double.tryParse(json['shipping_amount']?.toString() ?? json['shipping']?.toString() ?? '0.0') ?? 0.0,
      total: double.tryParse(json['grand_total']?.toString() ?? json['total']?.toString() ?? '0.0') ?? 0.0,
      createdAt: dateStr,
      items: orderItems,
      thumbnails: displayThumbs,
      extraCount: extra,
      shippingAddress: json['shipping_address'] is Map<String, dynamic> ? json['shipping_address'] as Map<String, dynamic> : null,
      notes: json['notes'],
      canBeCancelled: json['can_be_cancelled'] == true || (rawStatus == 'pending' || rawStatus == 'processing'),
    );
  }
}
