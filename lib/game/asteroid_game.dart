import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'player.dart';
import 'asteroid.dart';
import 'package:flutter/services.dart';
import '../widgets/lives_tracker.dart';
import '../screens/game_over.dart';
import 'package:firebase_database/firebase_database.dart';
import '../screens/game_screen.dart';
import '../widgets/boundary_box.dart';

class AsteroidGame extends FlameGame with KeyboardEvents {
  final BuildContext context;
  final void Function(String playerName) onRestartGame;
  bool isGameOver = false;

  AsteroidGame({required this.context, required this.onRestartGame});

  @override
  Color backgroundColor() => Colors.transparent;

  late final BoundaryBox boundaryBox;
  late Player player;
  late Timer _asteroidTimer;
  late LivesTracker livesTracker;
  late TextComponent elapsedTimeText;

  double _elapsedTime = 0;
  List<Asteroid> asteroids = [];

  final FocusNode _focusNode = FocusNode();
  final double boxMargin = 50.0;

  double spawnInterval = 0.25; // Initial interval

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _focusNode.requestFocus();

    _initializeBoundaryBox();

    print("onLoad called...");
    await _initializeGame();

    elapsedTimeText = TextComponent(
      text: 'Time: 0.00s',
      position: Vector2(900, 10),
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Orbitron',
          fontSize: 24,
        ),
      ),
    );
    add(elapsedTimeText);
  }

  Future<void> _initializeGame() async {
    livesTracker = LivesTracker(lives: 3);
    await add(livesTracker);

    // Load the player sprite
    player = Player(
      livesTracker: livesTracker,
      onGameOver: _handleGameOver,
      boundaryBox: boundaryBox,
    );
    Player.hasCollided = false;
    await add(player);

    // Set up the timer to spawn asteroids
    _asteroidTimer = Timer(spawnInterval, repeat: true, onTick: _spawnAsteroid);
    _asteroidTimer.start();

    _elapsedTime = 0;
    print("Timer started...");
  }

  void _initializeBoundaryBox() {
    boundaryBox = BoundaryBox(margin: boxMargin)
      ..size = size
      ..position = Vector2(0, 0);
    add(boundaryBox!);
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);

    if (boundaryBox == null || boundaryBox!.size == Vector2.zero()) return;

    // Update the elapsed time
    _elapsedTime += dt;

    // Decrease the spawn interval every 10 seconds (but ensure it does not go below 0.1)
    spawnInterval = 0.25 - (_elapsedTime / 20) * 0.02;
    spawnInterval = spawnInterval < 0.1 ? 0.1 : spawnInterval;

    // Update the timer
    _asteroidTimer.update(dt);

    // Update the elapsed time display
    elapsedTimeText.text = 'Time: ${_elapsedTime.toStringAsFixed(2)}s';

    for (Asteroid asteroid in asteroids) {
      asteroid.update(dt);
    }

    player.checkCollisions(asteroids);
    livesTracker.updateLives(player.lives);
  }

  void _spawnAsteroid() {
    print("Spawning asteroid...");
    Asteroid asteroid = Asteroid();
    add(asteroid);
    asteroids.add(asteroid);

    // Adjust the timer with the updated spawn interval
    _asteroidTimer = Timer(spawnInterval, repeat: true, onTick: _spawnAsteroid);
    _asteroidTimer.start();
  }

  void removeAsteroid(Asteroid asteroid) {
    asteroids.remove(asteroid);
    remove(asteroid);
  }

  void restartGame() async {
    print("Restart button pressed");

    _asteroidTimer.stop();
    _asteroidTimer.start();
    print("Timer reset...");

    for (final asteroid in asteroids) {
      if (contains(asteroid)) {
        remove(asteroid);
      }
    }
    asteroids.clear();
    print("Asteroids cleared!");

    player.resetLives();

    if (contains(player)) {
      print("Removing player: $player");
      remove(player);
    }
    print("Player removed!");

    if (contains(livesTracker)) {
      print("Removing Old LivesTracker");
      remove(livesTracker);
    }
    print("Old LivesTracker removed");

    await _initializeGame();
  }

  void _handleGameOver() {
    isGameOver = true;
    _asteroidTimer.stop();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          onSubmitScore: _submitBestTime,
          onRestart: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => GameScreen()),
            );
          },
          timeSurvived: _elapsedTime,
        ),
      ),
    );
  }

  void _submitBestTime(String playerName) async {
    if (playerName.isEmpty) return;

    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('leaderboard');

    await dbRef.push().set({
      'name': playerName,
      'time': double.parse(_elapsedTime.toStringAsFixed(2)),
    });

    print("Best time submitted to Firebase: ${_elapsedTime.toStringAsFixed(2)} seconds");
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (player.onKeyEvent(event, keysPressed)) {
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}