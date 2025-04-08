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
import '../widgets/boundary_box.dart';

class Player extends SpriteComponent with HasGameRef, KeyboardHandler, CollisionCallbacks {
  static bool _hasCollided = false;
  bool debugMode = false;

  static bool get hasCollided => _hasCollided;
  static set hasCollided(bool value) => _hasCollided = value;

  final VoidCallback onGameOver;

  Player({required this.livesTracker, required this.onGameOver}) : super(size: Vector2(100, 100));

  final LivesTracker livesTracker;

  final Map<LogicalKeyboardKey, bool> _keyStates = {};

  final Vector2 velocity = Vector2.zero();
  final double acceleration = 750.0;
  final double maxSpeed = 300.0;
  final double friction = 50.0;

  int lives = 3;

  double collisionCooldown = 1.0;
  double _collisionTimer = 0.0;

  late CircleHitbox playerHitbox;

  double hitboxRadius = 0.0;
  double _targetAngle = 0.0;

  // Rotation speed for user input
  final double rotationSpeed = 7.0;

  // Drift-related variables
  double _driftAngle = 0.0; // Keeps track of drift direction when input stops
  final double driftSpeed = 1.5; // Speed of drift, lower for slower drifting

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
        paint: Paint()..color = Color(0x55FF0000),
      ));
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      _keyStates[event.logicalKey] = true;
    } else if (event is KeyUpEvent) {
      _keyStates[event.logicalKey] = false;
    }
    return false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _movePlayerPhysics(dt);
    _updateCollisionCooldown(dt);
    _handleRotation(dt);  // Updated rotation handling
  }

  void _movePlayerPhysics(double dt) {
    if ((gameRef as AsteroidGame).isGameOver) return;

    Vector2 input = Vector2.zero();

    // Check for input to move the ship
    if (_keyStates[LogicalKeyboardKey.arrowLeft] == true || _keyStates[LogicalKeyboardKey.keyA] == true) {
      input.x -= 1;
    }
    if (_keyStates[LogicalKeyboardKey.arrowRight] == true || _keyStates[LogicalKeyboardKey.keyD] == true) {
      input.x += 1;
    }
    if (_keyStates[LogicalKeyboardKey.arrowUp] == true || _keyStates[LogicalKeyboardKey.keyW] == true) {
      input.y -= 1;
    }
    if (_keyStates[LogicalKeyboardKey.arrowDown] == true || _keyStates[LogicalKeyboardKey.keyS] == true) {
      input.y += 1;
    }

     // Dynamically boost acceleration when there's input
    double dynamicAcceleration = acceleration;
    if (input.length > 0) {
      dynamicAcceleration *= 1.3;  // You can tweak the 1.2 factor to adjust the boost amount
    }

    // Smoothly interpolate velocity
    if (input.length > 0) {
      input.normalize();
      velocity.add(input * dynamicAcceleration * dt);
    } else {
      if (velocity.length > 0) {
        // Apply stronger friction to decelerate faster
        Vector2 frictionForce = velocity.normalized() * friction * 2 * dt;
        velocity.sub(frictionForce);

        // If the velocity is very small, we set it to zero to avoid tiny movements
        if (velocity.length < 0.5) {
          velocity.setZero();
        }
      }
    }

    // Ensure the velocity doesn't exceed max speed
    if (velocity.length > maxSpeed) {
      velocity.normalize();
      velocity.scale(maxSpeed);
    }

    // Smooth out the movement by interpolating the position
    position += velocity * dt;
  }

  void _handleRotation(double dt) {
    // Skip angle update if no input or no movement
    if (velocity.length == 0 || !_keyStates.containsValue(true)) {
      // Continue drifting in the last direction for a brief time after input stops
      if (_driftAngle != 0) {
        double diff = _driftAngle - angle;
        diff = (diff + Math.pi) % (2 * Math.pi) - Math.pi; // Keep angle within [-π, π]

        double driftDecayFactor = 0.5; // Increased decay factor to stop drifting quicker
        _driftAngle -= Math.sin(diff) * Math.min(driftSpeed * dt, diff.abs()) * driftDecayFactor;

        angle += Math.sin(diff) * Math.min(driftSpeed * dt, diff.abs()); // Rotate with drift speed
      }
      return;
    }

    Vector2 input = Vector2.zero();
    bool hasInput = false;

    // Process user input to update target angle
    if (_keyStates[LogicalKeyboardKey.arrowLeft] == true || _keyStates[LogicalKeyboardKey.keyA] == true) {
      input.x -= 1;
      hasInput = true;
    }
    if (_keyStates[LogicalKeyboardKey.arrowRight] == true || _keyStates[LogicalKeyboardKey.keyD] == true) {
      input.x += 1;
      hasInput = true;
    }
    if (_keyStates[LogicalKeyboardKey.arrowUp] == true || _keyStates[LogicalKeyboardKey.keyW] == true) {
      input.y -= 1;
      hasInput = true;
    }
    if (_keyStates[LogicalKeyboardKey.arrowDown] == true || _keyStates[LogicalKeyboardKey.keyS] == true) {
      input.y += 1;
      hasInput = true;
    }

    if (hasInput) {
      input.normalize();
      _targetAngle = Math.atan2(input.y, input.x) + Math.pi / 2;

      // Reset drift angle immediately when input is active
      _driftAngle = _targetAngle;
    }

    double diff = _targetAngle - angle;
    diff = (diff + Math.pi) % (2 * Math.pi) - Math.pi; // Keep angle within [-π, π]

    double rotationStep = rotationSpeed * dt;

    // Apply rotation smoothing
    double angleDifference = diff.abs();
    double rotationMultiplier = Math.min(angleDifference / (Math.pi * 1.66), 1.0);
    rotationStep *= (1 + rotationMultiplier);

    if (angleDifference < rotationStep) {
      angle = _targetAngle;  // Snap to target angle if close
    } else {
      angle += rotationStep * (diff > 0 ? 1 : -1);
    }
  }

  void checkCollisions(List<Asteroid> asteroids) {
    if (_hasCollided || (gameRef as AsteroidGame).isGameOver) return;

    for (Asteroid asteroid in asteroids) {
      Vector2 playerCenter = position + Vector2(size.x / 2, size.y / 2);
      Vector2 asteroidCenter = asteroid.position + Vector2(asteroid.size.x / 2, asteroid.size.y / 2);

      double distance = playerCenter.distanceTo(asteroidCenter);

      double playerRadius = hitboxRadius;
      double asteroidRadius = Math.min(asteroid.size.x, asteroid.size.y) / 2;

      if (distance < (playerRadius + asteroidRadius)) {
        takeDamage();
        print("Collision!");

        gameRef.remove(asteroid);
        asteroids.remove(asteroid);
        break;
      }
    }
  }

  void takeDamage() {
    if (_hasCollided || lives <= 0 || (gameRef as AsteroidGame).isGameOver) return;

    _hasCollided = true;
    lives--;
    livesTracker.updateLives(lives);
    print("Collision! Player lost a life. Lives left: $lives");

    if (lives <= 0) {
      gameOver();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        _hasCollided = false;
      });
    }
  }

  void resetLives() {
    lives = 3;
    livesTracker.updateLives(lives);
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

  void gameOver() {
    onGameOver();
  }
}