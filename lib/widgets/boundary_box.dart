import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BoundaryBox extends PositionComponent {
  final double margin;

  BoundaryBox({required this.margin});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(50) // Faint outline
      ..style = PaintingStyle.stroke // Only the outline, no fill
      ..strokeWidth = 2.0;

    double boxWidth = size.x - margin * 2;
    double boxHeight = size.y - margin * 2;

    // Make the box more square by using the smaller dimension
    double boxSize = boxWidth < boxHeight ? boxWidth : boxHeight;

    // Draw the rectangle
    final rect = Rect.fromLTWH(
      (size.x - boxSize) / 2, // Center horizontally
      (size.y - boxSize) / 2, // Center vertically
      boxSize, // Use the calculated square size
      boxSize, // Keep the box square
    );
    canvas.drawRect(rect, paint);
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }

  // Expose the boundary rectangle for the player clamping
  Rect get boundaryRect {
    double boxWidth = size.x - margin * 2;
    double boxHeight = size.y - margin * 2;
    double boxSize = boxWidth < boxHeight ? boxWidth : boxHeight;

    double boxLeft = (size.x - boxSize) / 2;
    double boxTop = (size.y - boxSize) / 2;

    return Rect.fromLTWH(
      boxLeft,
      boxTop,
      boxSize,
      boxSize,
    );
  }

  @override
  bool containsPoint(Vector2 point) {
    // Define behavior if needed when checking for touches/collisions
    return super.containsPoint(point);
  }
}
