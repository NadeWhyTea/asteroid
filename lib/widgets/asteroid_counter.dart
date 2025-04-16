import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AsteroidCounter extends TextComponent {
  AsteroidCounter()
      : super(
    text: "Asteroids: 0",
    position: Vector2(915, 50), // Position on the screen
    textRenderer: TextPaint(
      style: TextStyle(
        fontSize: 24,
        color: Colors.white,
      ),
    ),
  );

  // Method to update the counter text
  void updateCounter(int count) {
    text = "Asteroids: $count";
  }
}