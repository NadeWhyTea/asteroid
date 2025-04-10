import 'dart:math' as Math;
import 'dart:ui';
import '../widgets/boundary_box.dart';
import 'asteroid_game.dart';
import 'player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'dart:math';
import 'package:flutter/material.dart';

class Asteroid extends SpriteComponent with HasGameRef, CollisionCallbacks {
  bool debugMode = false;
  static final Random _random = Random();
  late PolygonHitbox hitbox; //This under Asteroid() caused hitbox problems
  Vector2 velocity = Vector2.zero();
  late Vector2 targetPoint;

  Asteroid() : super(size: Vector2(75, 75)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    //print("Loading asteroid sprite...");
    sprite = await gameRef.loadSprite('sprites/asteroid.png');

    Vector2 screenSize = gameRef.size;
    Vector2 spawnPoint = getRandomSpawnPosition(screenSize);
    position = spawnPoint;

    BoundaryBox boundaryBox = gameRef.children.firstWhere(
            (child) => child is BoundaryBox) as BoundaryBox;
    
    targetPoint = getRandomPointWithinBoundary(boundaryBox);

    velocity = (targetPoint - position).normalized() * 100;

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

  Vector2 getRandomSpawnPosition(Vector2 screenSize) {
    int side = _random.nextInt(4); // 0: Top, 1: Bottom, 2: Left, 3: Right
    switch (side){
      case 0: // Top
        return Vector2(_random.nextDouble() * screenSize.x, -size.y);
      case 1: // Bottom
        return Vector2(_random.nextDouble() * screenSize.x, screenSize.y + size.y);
      case 2: // Left
        return Vector2(-size.x, _random.nextDouble() * screenSize.y);
      case 3:
      default:
        return Vector2(screenSize.x + size.x, _random.nextDouble() * screenSize.y);
    }
  }

  Vector2 getRandomPointWithinBoundary(BoundaryBox boundaryBox) {
    Rect boundaryRect = boundaryBox.boundaryRect; // Get the boundary rectangle

    // Generate a random point within the boundary rectangle
    double randomX = _random.nextDouble() * boundaryRect.width + boundaryRect.left;
    double randomY = _random.nextDouble() * boundaryRect.height + boundaryRect.top;

    return Vector2(randomX, randomY);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      (gameRef as AsteroidGame).removeAsteroid(this);

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
    position += velocity * dt;

    if (position.x < -size.x || position.x > gameRef.size.x + size.x ||
        position.y < -size.y || position.y > gameRef.size.y + size.y) {
      removeFromParent(); //Remove if out of bounds
    }
  }

  @override
  void onRemove() {
    super.onRemove();
    children.whereType<PolygonHitbox>().forEach((hitbox) {
      hitbox.removeFromParent();
    });
  }

  @override
  Rect toRect() {
    return Rect.fromLTWH(position.x, position.y, size.x, size.y);
  }
}



