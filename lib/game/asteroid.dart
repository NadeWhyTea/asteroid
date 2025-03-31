import 'dart:math' as Math;
import 'dart:ui';
import 'player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:math';

import 'package:flutter/material.dart';

class Asteroid extends SpriteComponent with HasGameRef, CollisionCallbacks {
  bool debugMode = true;
  static final Random _random = Random();

  Asteroid() : super(size: Vector2(75, 75)) {
    anchor = Anchor.center;
  }

  late PolygonHitbox hitbox;

  @override
  Future<void> onLoad() async {
    //print("Loading asteroid sprite...");
    sprite = await gameRef.loadSprite('sprites/asteroid.png');
    //print("Asteroid sprite loaded successfully!");
    position = Vector2(
      _random.nextDouble() * gameRef.size.x,
      -size.y, //Start off-screen
    );

    /*if (children
        .whereType<PolygonHitbox>()
        .isEmpty) {
      addOvalHitbox();
    }*/

    double semiMajorAxis = size.x / 2;
    double semiMinorAxis = size.y / 2;

    List<Vector2> ovalPoints = [];
    int numPoints = 50;

    for (int i = 0; i < numPoints; i++) {
      double angle = (i / numPoints) * Math.pi * 2;

      double x = Math.cos(angle) * semiMajorAxis;
      double y = Math.sin(angle) * semiMinorAxis;

      ovalPoints.add(Vector2(x, y));
    }

    hitbox = (PolygonHitbox(ovalPoints, position: Vector2.zero()));
    add(hitbox);

    if (debugMode){
    add(CircleComponent(
      radius: Math.min(size.x, size.y) / 2,
      position: Vector2.zero(),
      paint: Paint()..color = Color(0x55FF0000),
    ));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
        removeFromParent();
        print("Asteroid destroyed!");

        children.whereType<PolygonHitbox>().forEach((hitbox) {
          hitbox.removeFromParent();
        });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += 100 * dt;
    if (position.y > gameRef.size.y) {
      removeFromParent(); //Remove if out of bounds
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    children.whereType<PolygonHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });
    print("Asteroid and hitbox removed!");
  }

  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }
}



