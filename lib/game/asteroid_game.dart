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

class AsteroidGame extends FlameGame with KeyboardEvents{
  final BuildContext context;

  AsteroidGame({required this.context});

  @override
  Color backgroundColor() => Colors.transparent;

  late Player player;
  late Timer _asteroidTimer;
  late LivesTracker livesTracker;

  List<Asteroid> asteroids = [];

  final FocusNode _focusNode = FocusNode();

  @override
  Future<void> onLoad() async {
    super.onLoad();
    //debugMode = true;
    _focusNode.requestFocus();

    print("onLoad called...");

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
    //print("Timer started...");
  }

    @override
    void update(double dt) {
      super.update(dt);

      //debugMode = true;
      //print("Game updating... dt: $dt");

      // Update the timer
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

  void restartGame() {
    player.lives = 3;
    player.livesTracker.updateLives(player.lives);

    print("Clearing asteroids...");
    for (Asteroid asteroid in asteroids) {
      if (contains(asteroid)) {
        print("Removing asteroid: $asteroid");
        remove(asteroid);
      }
    }
    asteroids.clear();
    print("Asteroids cleared!");

    if (contains(player)){
      print("Removing player: $player");
      remove(player);
    }

    print("Player removed!");

    livesTracker = LivesTracker(lives: 3);
    add(livesTracker);

    player = Player(
      livesTracker: livesTracker,
      onGameOver: _handleGameOver,
    );

    add(player);

    _asteroidTimer.start();
  }

  void _handleGameOver() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverScreen(
          onRestart: () {
            restartGame();
          },
        ),
      ),
    );
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed){
    if (player.onKeyEvent(event, keysPressed)){
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}