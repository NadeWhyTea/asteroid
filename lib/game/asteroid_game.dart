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

class AsteroidGame extends FlameGame with KeyboardEvents{
  final BuildContext context;
  final void Function(String playerName) onRestartGame;
  bool isGameOver = false;

  AsteroidGame({required this.context, required this.onRestartGame});

  @override
  Color backgroundColor() => Colors.transparent;

  late Player player;
  late Timer _asteroidTimer;
  late LivesTracker livesTracker;

  double _elapsedTime = 0;

  List<Asteroid> asteroids = [];

  final FocusNode _focusNode = FocusNode();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //debugMode = true;
    _focusNode.requestFocus();

    print("onLoad called...");
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    livesTracker = LivesTracker(lives : 3);
    await add(livesTracker);

    // Load the player sprite
    player = Player(
        livesTracker: livesTracker,
        onGameOver: _handleGameOver,
    );
    await add(player);

    // Set up the timer to spawn asteroids
    _asteroidTimer = Timer(0.25, repeat: false);
    _asteroidTimer.start();

    _elapsedTime = 0;
    print("Timer started...");
  }

    @override
    void update(double dt) {
      if (isGameOver) return;

      super.update(dt);

      //debugMode = true;
      //print("Game updating... dt: $dt");

      // Update the timer
      _elapsedTime += dt;
      _asteroidTimer.update(dt);
      //print("Timer current: ${_asteroidTimer.current}");

      if (_asteroidTimer.finished) {
        //print("Timer finished. Spawning asteroid...");
        // Spawn an asteroid if the timer is finished
        _spawnAsteroid();
        _asteroidTimer.start();
      }

      for (Asteroid asteroid in asteroids){
        asteroid.update(dt);
      }

      player.checkCollisions(asteroids);

      livesTracker.updateLives(player.lives);
    }


  void _spawnAsteroid() {
    //print("Spawning asteroid...");
    // Add an asteroid to the game
    Asteroid asteroid = Asteroid();
    add(asteroid);
    asteroids.add(asteroid);
  }

  void removeAsteroid(Asteroid asteroid){
    asteroids.remove(asteroid);
    remove(asteroid);
  }

  void restartGame() async {
    print("Restart button pressed");

    _asteroidTimer.stop();
    _asteroidTimer.start();
    print("Timer reset...");

    print("Clearing asteroids...");
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          onSubmitScore: _submitBestTime,
          onRestart: restartGame,
          timeSurvived: _elapsedTime,
        ),
      ),
    );
  }

  void _submitBestTime(String playerName) async {
    if (playerName.isEmpty) return;

    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('leaderboard');

    await dbRef.push().set({
      'name': playerName, // Use player input
      'time': double.parse(_elapsedTime.toStringAsFixed(2)),
    });

    print("Best time submitted to Firebase: ${_elapsedTime.toStringAsFixed(2)} seconds");
  }


  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed){
    if (player.onKeyEvent(event, keysPressed)){
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}