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

  late BoundaryBox boundaryBox; // Declare boundaryBox late, but initialize later
  late Player player;
  late Timer _asteroidTimer;
  late LivesTracker livesTracker;
  late TextComponent elapsedTimeText;

  double _elapsedTime = 0;
  List<Asteroid> asteroids = [];

  final FocusNode _focusNode = FocusNode();
  final double boxMargin = 50.0; // Set your desired margin here

  AsteroidGame({required this.context, required this.onRestartGame});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _focusNode.requestFocus();

    print("onLoad called...");
    await _initializeGame();

    // Initialize the boundary box after game size is set
    _initializeBoundaryBox();

    elapsedTimeText = TextComponent(
      text: 'Time: 0.00s',
      position: Vector2(900,10),
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
    );
    Player.hasCollided = false;
    await add(player);

    // Set up the timer to spawn asteroids
    _asteroidTimer = Timer(0.25, repeat: false);
    _asteroidTimer.start();

    _elapsedTime = 0;
    print("Timer started...");
  }

  void _initializeBoundaryBox() {
    // Initialize boundary box after the size is available
    boundaryBox = BoundaryBox(margin: boxMargin)
      ..size = size; // Set the size to match the game area

    boundaryBox.position = Vector2(0, 0); // Centered, no margin

    add(boundaryBox);  // Add the boundary box to the game
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);

    // Ensure boundaryBox is properly initialized before using
    if (boundaryBox.size == Vector2.zero()) {
      return; // If the boundary box size is not set, do nothing
    }

    // Get the boundary rectangle from the boundary box
    Rect boundaryRect = boundaryBox.boundaryRect;

    // Clamp the player's position to stay within the boundary rectangle
    player.position.x = player.position.x.clamp(boundaryRect.left, boundaryRect.right);
    player.position.y = player.position.y.clamp(boundaryRect.top, boundaryRect.bottom);

    // Update the timer
    _elapsedTime += dt;
    _asteroidTimer.update(dt);

    elapsedTimeText.text = 'Time: ${_elapsedTime.toStringAsFixed(2)}s';

    if (_asteroidTimer.finished) {
      _spawnAsteroid();
      _asteroidTimer.start();
    }

    for (Asteroid asteroid in asteroids) {
      asteroid.update(dt);
    }

    player.checkCollisions(asteroids);
    livesTracker.updateLives(player.lives);
  }

  void _spawnAsteroid() {
    Asteroid asteroid = Asteroid();
    add(asteroid);
    asteroids.add(asteroid);
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

    // Clear asteroids
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

    // Navigate to GameOverScreen with the player's time and a callback
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