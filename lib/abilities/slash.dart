import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as Math;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'dart:math' as Math;

import '../game/asteroid.dart';
import '../game/asteroid_game.dart';

class Slash extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final double slashSpeed = 250;
  late Vector2 velocity;

  // Declare the hitbox variable
  late PolygonHitbox slashHitbox;

  Slash({
    required Vector2 playerPosition,
    required Vector2 playerSize,
    required double playerAngle,
    required Vector2 playerVelocity,
  }) : super(
    size: Vector2(100, 100),
    angle: playerAngle + Math.pi,
    anchor: Anchor.center, // Important for correct rotation
    priority: 100, // Renders in front of most other components
  ) {
    final fixedAngle = playerAngle - Math.pi / 2;
    // Offset the slash forward based on player rotation
    final offset = Vector2(Math.cos(fixedAngle), Math.sin(fixedAngle)) *
        (playerSize.length / 2 - 50);

    position = playerPosition + offset;

    // Move in the same rotated direction
    velocity = Vector2(Math.cos(fixedAngle), Math.sin(fixedAngle)) * slashSpeed + playerVelocity;
  }

  @override
  Future<void> onLoad() async {
    final slashSprite = await Flame.images.load('sprites/slash_spritesheet.png');

    animation = SpriteAnimation.fromFrameData(
      slashSprite,
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.08,
        textureSize: Vector2(1920 / 5, 384), // = Vector2(384, 384) // Adjust based on your sprite sheet
        loop: false,
      ),
    );

    slashHitbox = PolygonHitbox.relative([
      Vector2(-0.5, -0.5),
      Vector2(0.5, -0.5),
      Vector2(0.5, 0.5),
      Vector2(-0.5, 0.5),
    ], parentSize: size);

    add(slashHitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;

    // Remove the slash when its animation is done
    if (animationTicker?.done() == true) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Asteroid) {
      other.removeFromParent();
      (gameRef as AsteroidGame).removeAsteroid(other);
      print("Asteroid slashed!");
    }
  }
}
