import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import 'package:gif_view/gif_view.dart';
import '../styles/button_styles.dart';

class GameOverScreen extends StatelessWidget {
  final VoidCallback onRestart;

  const GameOverScreen({Key? key, required this.onRestart}) : super(key: key);

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
                      builder: (context) =>
                          HomeScreen(title: 'Asteroid Game Home Screen'),
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

                CustomButton(
                  text: 'Restart',
                  onPressed: () {
                    Navigator.pop(context);
                    print("Restart button pressed");
                    onRestart();
                  },
                  buttonStyle: restartButtonStyle,
                  textStyle: TextStyle(color: Colors.red, fontSize: 20, fontFamily: 'Orbitron'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}