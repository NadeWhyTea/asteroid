import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';

class Player extends SpriteComponent with HasGameRef, KeyboardHandler {
  Player() : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('sprites/ship.png');
    position = gameRef.size / 2;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed){
    final double moveSpeed = 5.0;

    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        position.x -= moveSpeed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        position.x += moveSpeed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        position.y -= moveSpeed;
      }
      if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        position.y += moveSpeed;
      }
    }
      return false;
  }
}

