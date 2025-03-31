import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'dart:math' as Math;
import 'asteroid.dart';
import '../widgets/lives_tracker.dart';
import 'asteroid_game.dart';
import '../screens/game_over.dart';

class Player extends SpriteComponent with HasGameRef, KeyboardHandler, CollisionCallbacks {
  static bool _hasCollided = false;
  bool debugMode = true;

  static bool get hasCollided => _hasCollided;
  static set hasCollided(bool value) => _hasCollided = value;

  final VoidCallback onGameOver;

  Player({required this.livesTracker, required this.onGameOver}) : super(size: Vector2(100, 100));

  final LivesTracker livesTracker;

  final Map<LogicalKeyboardKey, bool> _keyStates = {};

  double moveSpeed = 7.5;
  int lives = 3;

  double collisionCooldown = 1.0;
  double _collisionTimer = 0.0;

  late CircleHitbox playerHitbox;

  double hitboxRadius = 0.0;

  @override
  Future<void> onLoad() async {
    print("Loading player sprite...");
    sprite = await gameRef.loadSprite('sprites/ship.png');
    print("Player sprite loaded successfully!");

    position = gameRef.size / 2;

    anchor = Anchor.center;

    width = sprite!.originalSize.x * 0.25;
    height = sprite!.originalSize.y * 0.25;

    size = Vector2(width, height);

    hitboxRadius = Math.min(width, height) / 2;

    double hitboxScale = 0.75;
    hitboxRadius *= hitboxScale;

    double offsetX = (width - hitboxRadius * 2) / 2;
    double offsetY = (height - hitboxRadius * 2) / 2;

    playerHitbox = CircleHitbox(radius: hitboxRadius);
    playerHitbox.position = Vector2(offsetX, offsetY);
    add(playerHitbox);

    if (debugMode) {
      add(CircleComponent(
        radius: hitboxRadius,
        position: Vector2(offsetX, offsetY),
        paint: Paint()
          ..color = Color(0x55FF0000),
      ));
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      _keyStates[event.logicalKey] = true;
      //print("Key Down: $keysPressed");
    }
    else if (event is KeyUpEvent) {
      _keyStates[event.logicalKey] = false;
      //print("Key Up: $keysPressed");
    }

    return false;
  }

  @override
  void update(double dt){
    super.update(dt);

    _movePlayer();
    _updateCollisionCooldown(dt);
  }

  void _movePlayer()
  {
    double deltaX = 0;
    double deltaY = 0;

    if (_keyStates[LogicalKeyboardKey.arrowLeft] == true) {
      //print("Arrow Left Pressed");
      deltaX -= moveSpeed;
    }
    if (_keyStates[LogicalKeyboardKey.arrowRight] == true) {
      //print("Arrow Right Pressed");
      deltaX += moveSpeed;
    }
    if (_keyStates[LogicalKeyboardKey.arrowUp] == true) {
      //print("Arrow Up Pressed");
      deltaY -= moveSpeed;
    }
    if (_keyStates[LogicalKeyboardKey.arrowDown] == true) {
      //print("Arrow Down Pressed");
      deltaY += moveSpeed;
    }

    position.x += deltaX;
    position.y += deltaY;

    //print("deltaX is: $deltaX");
    //print("deltaX is: $deltaY");

    if (deltaX != 0 || deltaY != 0){
      double angle = Math.atan2(deltaY, deltaX);

      angle += Math.pi / 2;

      this.angle = angle;
    }
  }

  void checkCollisions(List<Asteroid> asteroids) {
    if (_hasCollided) return;

    for (Asteroid asteroid in asteroids){
      Vector2 playerCenter = position + Vector2(size.x / 2, size.y / 2);
      Vector2 asteroidCenter = asteroid.position + Vector2(asteroid.size.x / 2, asteroid.size.y / 2);

      double distance = playerCenter.distanceTo(asteroidCenter);

      double playerRadius = hitboxRadius;
      double asteroidRadius = Math.min(asteroid.size.x, asteroid.size.y) / 2;

      if (distance < (playerRadius + asteroidRadius)){
        takeDamage();
        print("Collision!");

        gameRef.remove(asteroid);
        asteroids.remove(asteroid);
        break;
      }
    }
  }

  void takeDamage() {
    int j = 0;
    if (_hasCollided) return;

    _hasCollided = true;
    lives--;
    j++;
    livesTracker.updateLives(lives);
    print("Collision! Player lost a life. Lives left: $lives , $j iterations");

    if (lives <= 0) {
      gameOver();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        _hasCollided = false;
      });
    }
  }

  void _updateCollisionCooldown(double dt) {
    if (_hasCollided) {
      _collisionTimer += dt;
      if (_collisionTimer >= collisionCooldown) {
        _hasCollided = false;
        _collisionTimer = 0.0;
      }
    }
  }

  void gameOver(){
    //print("Game Over!");
    onGameOver();
  }
}


