import 'package:flame/components.dart';
import 'dart:math';

class Asteroid extends SpriteComponent with HasGameRef{
  static final Random_random = Random();

  Asteroid() : super(size: Vector2(40,40));

  @override
  Future<void> onLoad() async {
    sprite
  }
}

