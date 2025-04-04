import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import 'package:gif_view/gif_view.dart';
import '../styles/button_styles.dart';

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body:Stack(
        children: [
          Positioned.fill(
            child: GifView(
              image: AssetImage('assets/images/leaderboardBackground.gif'),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: MouseRegion(
              onEnter:(_){
              },
              onExit:(_){
              },
              child: CustomButton(
                text: 'Return to Home',
                onPressed:()
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(title: 'Asteroid Game Home Screen')),
                  );
                },
                buttonStyle: returnButtonStyle,
              ),
            ),
          ),

          Center(
            child: Text(
              'Leaderboard will be here.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}