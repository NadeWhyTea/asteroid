import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import '../styles/button_styles.dart';
import 'package:flame/game.dart';
import '../game/asteroid_game.dart';

class GameScreen extends StatelessWidget {
  final FocusNode _focusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus){
        },

      child: Stack(
        children: [
          // This will render the background GIF first
          Positioned.fill(
            child: Image.asset(
              'assets/images/gameBackground.gif',
              fit: BoxFit.cover,
            ),
          ),

          // This will render the AsteroidGame on top of the background
          Positioned.fill(
            child: GameWidget(
              game: AsteroidGame(context: context),
            ),// This will load the AsteroidGame
          ),

          // Button to return to the home screen
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
      ),
    );
  }
}
