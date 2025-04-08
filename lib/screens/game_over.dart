import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import '../styles/button_styles.dart';
import 'package:flame/game.dart';
import '../game/asteroid_game.dart';
import 'package:gif_view/gif_view.dart';

class GameOverScreen extends StatefulWidget {
  final void Function(String playerName) onSubmitScore;
  final void Function() onRestart;
  final double timeSurvived;

  const GameOverScreen({
    Key? key,
    required this.onSubmitScore,
    required this.onRestart,
    required this.timeSurvived,
  }) : super(key: key);

  @override
  _GameOverScreenState createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  TextEditingController _nameController = TextEditingController();
  bool _hasSubmittedScore = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GifView(
              image: AssetImage('assets/images/gameOverBackground.gif'),
              fit: BoxFit.cover,
            ),
          ),
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Game Over',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    color: Colors.red,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.white10,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Conditionally show name input and submit button if score is not submitted
                if (!_hasSubmittedScore) ...[
                  // Player name input with adjusted width
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: 300, // Limit width of input field
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'Submit Score',
                    onPressed: () {
                      String playerName = _nameController.text.trim();
                      if (playerName.isNotEmpty) {
                        widget.onSubmitScore(playerName);
                        setState(() {
                          _hasSubmittedScore = true; // Hide input and button
                        });
                      }
                    },
                    buttonStyle: restartButtonStyle,
                    textStyle: TextStyle(color: Colors.red, fontSize: 20, fontFamily: 'Orbitron'),
                  ),
                ],
                // Option to restart the game
                if (_hasSubmittedScore) ...[
                  CustomButton(
                    text: 'Restart Game',
                    onPressed: widget.onRestart,
                    buttonStyle: restartButtonStyle,
                    textStyle: TextStyle(color: Colors.red, fontSize: 20, fontFamily: 'Orbitron'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
