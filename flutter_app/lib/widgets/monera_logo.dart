// lib/widgets/monera_logo.dart
import 'package:flutter/material.dart';

enum MoneraLogoVariant {
  icon,
  full,
  horizontal,
}

class MoneraLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final MoneraLogoVariant variant;

  const MoneraLogo({
    super.key,
    this.size = 36.0,
    this.color,
    this.variant = MoneraLogoVariant.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;

    if (variant == MoneraLogoVariant.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(size, size * 0.8),
            painter: _MoneraEmblemPainter(color: effectiveColor),
          ),
          SizedBox(width: size * 0.3),
          Text(
            'MONERA',
            style: TextStyle(
              color: effectiveColor,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.65,
              letterSpacing: 2.0,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      );
    }

    if (variant == MoneraLogoVariant.full) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomPaint(
            size: Size(size, size * 0.8),
            painter: _MoneraEmblemPainter(color: effectiveColor),
          ),
          SizedBox(height: size * 0.15),
          Text(
            'MONERA',
            style: TextStyle(
              color: effectiveColor,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.28,
              letterSpacing: 2.5,
              fontFamily: 'PlusJakartaSans',
            ),
          ),
        ],
      );
    }

    // Default icon only
    return CustomPaint(
      size: Size(size, size * 0.8),
      painter: _MoneraEmblemPainter(color: effectiveColor),
    );
  }
}

class _MoneraEmblemPainter extends CustomPainter {
  final Color color;

  _MoneraEmblemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // ViewBox mapping from (0,0, 260, 210) to (size.width, size.height)
    final scaleX = size.width / 260.0;
    final scaleY = size.height / 210.0;

    Offset pt(double x, double y) => Offset(x * scaleX, y * scaleY);

    // 1. Central Inverted Triangle
    final triPath = Path()
      ..moveTo(pt(88, 10).dx, pt(88, 10).dy)
      ..lineTo(pt(172, 10).dx, pt(172, 10).dy)
      ..lineTo(pt(130, 78).dx, pt(130, 78).dy)
      ..close();
    canvas.drawPath(triPath, paint);

    // 2. Outer Winged M Chevron
    final mPath = Path()
      ..moveTo(pt(10, 10).dx, pt(10, 10).dy)
      ..lineTo(pt(66, 10).dx, pt(66, 10).dy)
      ..lineTo(pt(130, 110).dx, pt(130, 110).dy)
      ..lineTo(pt(194, 10).dx, pt(194, 10).dy)
      ..lineTo(pt(250, 10).dx, pt(250, 10).dy)
      ..lineTo(pt(130, 195).dx, pt(130, 195).dy)
      ..close();
    canvas.drawPath(mPath, paint);

    // 3. Left Flanking Triangle (Pointing UP)
    final leftPath = Path()
      ..moveTo(pt(32, 108).dx, pt(32, 108).dy)
      ..lineTo(pt(5, 150).dx, pt(5, 150).dy)
      ..lineTo(pt(59, 150).dx, pt(59, 150).dy)
      ..close();
    canvas.drawPath(leftPath, paint);

    // 4. Right Flanking Triangle (Pointing UP)
    final rightPath = Path()
      ..moveTo(pt(228, 108).dx, pt(228, 108).dy)
      ..lineTo(pt(201, 150).dx, pt(201, 150).dy)
      ..lineTo(pt(255, 150).dx, pt(255, 150).dy)
      ..close();
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MoneraEmblemPainter oldDelegate) =>
      oldDelegate.color != color;
}
