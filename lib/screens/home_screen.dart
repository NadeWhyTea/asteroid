import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import '../widgets/custom_button.dart';
import 'package:gif_view/gif_view.dart';

class HomeScreen extends StatelessWidget {
  final String title;

  const HomeScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Stack(
        children: [
          //GIF Background using gif_view package
          Positioned.fill(
            child: GifView(
              image: AssetImage('assets/images/asteroidBackground.gif'),
              fit: BoxFit.cover,
            ),

          ),

          //Title in Center
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Asteroids',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Start Button
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: MouseRegion(
                onEnter:(_){
                },
                onExit:(_){
                },
                child: CustomButton(
                  text: 'Start Game',
                  onPressed:()
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameScreen()),
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                  child: MouseRegion(
                      onEnter:(_){
                      },
                      onExit:(_){
                      },
                      child: CustomButton(
                        text: 'Leaderboard',
                        onPressed:()
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                          );
                        },

                      )
                  )
              )
          )
        ],
      ),
    );
  }
}