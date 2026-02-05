import 'package:flutter/material.dart';

class MedicalBackgroundPainter extends CustomPainter {
  final Color color;

  MedicalBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Drawing some abstract rounded capsule paths like in the image
    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.6)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..arcToPoint(
        Offset(size.width * 0.5, size.height * 0.8),
        radius: const Radius.circular(60),
        clockwise: true,
      )
      ..lineTo(size.width * 0.2, size.height * 0.8);

    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.3)
      ..arcToPoint(
        Offset(size.width * 0.4, size.height * 0.5),
        radius: const Radius.circular(80),
        clockwise: false,
      )
      ..lineTo(size.width * 0.9, size.height * 0.5);

    canvas.drawPath(path2, paint);

    // Add some glow points
    final glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.7),
      100,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.4),
      120,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
