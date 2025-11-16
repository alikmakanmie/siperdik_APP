import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  
  const AppLogo({
    Key? key,
    this.size = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size * 1.167),
          painter: LogoPainter(),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SIPERDIK BAWASLU',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            Text(
              'KABUPATEN 50 KOTA',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = AppColors.logoGold;
    final paint2 = Paint()..color = AppColors.logoRed;
    final paint3 = Paint()..color = AppColors.logoWhite;
    
    // Outer hexagon (gold)
    final path1 = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.75)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.75)
      ..lineTo(0, size.height * 0.25)
      ..close();
    canvas.drawPath(path1, paint1);
    
    // Middle hexagon (red)
    final path2 = Path()
      ..moveTo(size.width / 2, size.height * 0.14)
      ..lineTo(size.width * 0.83, size.height * 0.32)
      ..lineTo(size.width * 0.83, size.height * 0.68)
      ..lineTo(size.width / 2, size.height * 0.86)
      ..lineTo(size.width * 0.17, size.height * 0.68)
      ..lineTo(size.width * 0.17, size.height * 0.32)
      ..close();
    canvas.drawPath(path2, paint2);
    
    // Inner hexagon (white)
    final path3 = Path()
      ..moveTo(size.width / 2, size.height * 0.29)
      ..lineTo(size.width * 0.67, size.height * 0.375)
      ..lineTo(size.width * 0.67, size.height * 0.625)
      ..lineTo(size.width / 2, size.height * 0.71)
      ..lineTo(size.width * 0.33, size.height * 0.625)
      ..lineTo(size.width * 0.33, size.height * 0.375)
      ..close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
