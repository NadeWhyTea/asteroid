import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class LivesTracker extends PositionComponent with HasGameRef {
  late int lives;
  List<SpriteAnimationComponent> hearts = [];

  LivesTracker({required this.lives});

  @override
  Future<void> onLoad() async {
    final heartSprite = await Flame.images.load(
        'sprites/pixel-heart-spritesheet.png');

      final animation = SpriteAnimation.fromFrameData(
        heartSprite,
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize:Vector2(200,200),
      )
    );

    for (int i = 0; i < lives; i++) {
      var heart = SpriteAnimationComponent(
          animation: animation,
          size: Vector2(75, 75),
          position: Vector2 ((i * 75) + 1675, 20),
      );
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