import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import '../styles/button_styles.dart';
import 'package:flame/game.dart';
import '../game/asteroid_game.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AsteroidGame _game;

  @override
  void initState() {
    super.initState();
    // Initialize the game and pass the callback for restart
    _initializeGame();
  }

  void _initializeGame() {
    _game = AsteroidGame(context: context, onRestartGame: _restartGame);
  }

  // Method to handle restarting the game without recreating the game instance
  void _restartGame(String playerName) {
    setState(() {
      // Simply reset the game logic instead of creating a new game instance
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background GIF
          Positioned.fill(
            child: Image.asset(
              'assets/images/gameBackground.gif',
              fit: BoxFit.cover,
            ),
          ),

          // The AsteroidGame widget will be placed on top of the background
          Positioned.fill(
            child: GameWidget(
              game: _game,
            ),
          ),

          // Return to Home button
          Positioned(
            left: 10,
            top: 10,
            child: MouseRegion(
              onEnter: (_) {},
              onExit: (_) {},
              child: CustomButton(
                text: 'Return to Home',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(title: 'Asteroid Game Home Screen'),
                    ),
                  );
                },
                buttonStyle: returnButtonStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
