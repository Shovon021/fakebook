import 'package:flutter/material.dart';

/// Custom Facebook Messenger icon that matches the real Messenger logo
class MessengerIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MessengerIcon({
    super.key,
    this.size = 24,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MessengerIconPainter(color: color),
    );
  }
}

class _MessengerIconPainter extends CustomPainter {
  final Color color;

  _MessengerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;



    // Main chat bubble shape (rounded with pointed bottom)
    final path = Path();
    
    final w = size.width;
    final h = size.height;
    
    // Start from bottom point
    path.moveTo(w * 0.25, h * 0.85);
    
    // Left side going up
    path.quadraticBezierTo(w * 0.05, h * 0.75, w * 0.05, h * 0.45);
    
    // Top left curve
    path.quadraticBezierTo(w * 0.05, h * 0.15, w * 0.35, h * 0.12);
    
    // Top
    path.lineTo(w * 0.65, h * 0.12);
    
    // Top right curve
    path.quadraticBezierTo(w * 0.95, h * 0.15, w * 0.95, h * 0.45);
    
    // Right side going down
    path.quadraticBezierTo(w * 0.95, h * 0.75, w * 0.75, h * 0.85);
    
    // Bottom right
    path.lineTo(w * 0.55, h * 0.85);
    
    // Bottom point (chat tail)
    path.lineTo(w * 0.35, h * 0.98);
    path.lineTo(w * 0.35, h * 0.85);
    
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Lightning bolt inside (Messenger signature)
    final boltPath = Path();
    
    // Lightning bolt shape
    boltPath.moveTo(w * 0.55, h * 0.28);
    boltPath.lineTo(w * 0.35, h * 0.52);
    boltPath.lineTo(w * 0.48, h * 0.52);
    boltPath.lineTo(w * 0.42, h * 0.72);
    boltPath.lineTo(w * 0.65, h * 0.45);
    boltPath.lineTo(w * 0.52, h * 0.45);
    boltPath.close();
    
    final boltPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(boltPath, boltPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
