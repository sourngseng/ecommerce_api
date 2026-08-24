import 'package:flutter/material.dart';

class ShoppingBagIcon extends StatelessWidget {
  final double size;

  const ShoppingBagIcon({
    super.key,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft floor shadow
          Positioned(
            bottom: 0,
            child: Container(
              width: size * 0.85,
              height: 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.elliptical(size * 0.85, 14)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x14000000),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Custom Bag Drawing
          Positioned.fill(
            child: CustomPaint(
              painter: _ShoppingBagPainter(),
            ),
          ),

          // Shopping Cart Symbol on bag
          Positioned(
            bottom: size * 0.30,
            child: Icon(
              Icons.shopping_cart_outlined,
              size: size * 0.36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Handles Paint (Dark slate / Navy blue)
    final handlePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    // Front Handle
    final handlePath = Path();
    handlePath.moveTo(w * 0.38, h * 0.40);
    handlePath.cubicTo(
      w * 0.38, h * 0.05,
      w * 0.62, h * 0.05,
      w * 0.62, h * 0.40,
    );
    canvas.drawPath(handlePath, handlePaint);

    // Left side 3D fold (Darker orange)
    final leftFoldPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE04D00), Color(0xFFCC4400)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final leftFoldPath = Path();
    leftFoldPath.moveTo(w * 0.26, h * 0.36);
    leftFoldPath.lineTo(w * 0.16, h * 0.88);
    leftFoldPath.lineTo(w * 0.28, h * 0.92);
    leftFoldPath.lineTo(w * 0.36, h * 0.36);
    leftFoldPath.close();
    canvas.drawPath(leftFoldPath, leftFoldPaint);

    // Main Bag Body (Bright Orange Gradient)
    final bagPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7A1A), Color(0xFFFF5500), Color(0xFFE64D00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bagPath = Path();
    bagPath.moveTo(w * 0.33, h * 0.34);
    bagPath.lineTo(w * 0.67, h * 0.34);
    bagPath.lineTo(w * 0.80, h * 0.90);
    bagPath.lineTo(w * 0.20, h * 0.90);
    bagPath.close();

    // Soft rounded corners for bag
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.34, w * 0.60, h * 0.56),
        Radius.circular(w * 0.06),
      ),
      bagPaint,
    );

    // Handle Rivet Dots
    final dotPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(w * 0.39, h * 0.38), w * 0.024, dotPaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.38), w * 0.024, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
