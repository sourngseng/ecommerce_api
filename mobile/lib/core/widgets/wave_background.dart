import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomCurvedWave extends StatelessWidget {
  final double height;
  final Widget? child;

  const BottomCurvedWave({
    super.key,
    this.height = 180,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Background soft highlight wave
          Positioned.fill(
            child: CustomPaint(
              painter: _SoftWavePainter(),
            ),
          ),
          // Main gradient wave
          Positioned.fill(
            child: CustomPaint(
              painter: _MainWavePainter(),
              child: child != null
                  ? Align(
                      alignment: Alignment.center,
                      child: child,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.waveGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final path = Path();
    path.moveTo(0, size.height * 0.45);

    // First curve
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.55,
      size.height * 0.35,
    );

    // Second curve
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.60,
      size.width,
      size.height * 0.25,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SoftWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x59FF994D);

    final path = Path();
    path.moveTo(0, size.height * 0.25);

    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.55,
      size.width * 0.70,
      size.height * 0.15,
    );

    path.quadraticBezierTo(
      size.width * 0.90,
      0,
      size.width,
      size.height * 0.10,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
