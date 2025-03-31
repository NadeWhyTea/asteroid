import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class LivesTracker extends PositionComponent with HasGameRef {
  late int lives;
  List<SpriteComponent> hearts = [];

  LivesTracker({required this.lives});

  @override
  Future<void> onLoad() async {
    final heartSprite = await Sprite.load('sprites/pixel-heart.gif');

    for (int i = 0; i < lives; i++) {
      var heart = SpriteComponent(sprite: heartSprite, size: Vector2(50, 50));
      heart.position = Vector2 ((i * 50) + 1750, 20);
      hearts.add(heart);
      add(heart);
    }
  }

  void updateLives(int newLives) {
    lives = newLives.clamp(0, lives);

    //Hide hearts when lives decrease
    for (int i = hearts.length - 1; i >= lives; i--) {
      remove(hearts[i]);
      hearts.removeAt(i);
    }
  }
}