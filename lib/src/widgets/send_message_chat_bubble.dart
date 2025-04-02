import 'package:flutter/material.dart';

class CustomChatBubble extends CustomPainter {
  CustomChatBubble({required this.color, required this.isOwn});

  final Color color;
  final bool isOwn;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Draw the bubble body
    final RRect bubbleBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(20), // Rounded corners
    );
    canvas.drawRRect(bubbleBody, paint);

    // Draw the bubble tail
    final Path bubbleTail = Path();
    if (isOwn) {
      bubbleTail.moveTo(size.width-5, size.height / 2 - 12); // Start point
      bubbleTail.lineTo(size.width + 10, size.height / 2); // Tip of the tail
      bubbleTail.lineTo(size.width-5, size.height / 2 + 12); // End point
    } else {
      bubbleTail.moveTo(5, size.height / 2 - 8); // Start point
      bubbleTail.lineTo(-10, size.height / 2); // Tip of the tail
      bubbleTail.lineTo(5, size.height / 2 + 8); // End point
    }
    bubbleTail.close();

    canvas.drawPath(bubbleTail, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // Always repaint for dynamic updates
  }
}
