import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';
import 'package:gif_view/gif_view.dart';
import '../styles/button_styles.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final DatabaseReference _leaderboardRef =
  FirebaseDatabase.instance.ref('leaderboard');

  Future<List<Map<String, dynamic>>> _getLeaderboardData() async {
    try {
      final snapshot = await _leaderboardRef.get();
      List<Map<String, dynamic>> leaderboard = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          leaderboard.add({
            'name': value['name'],
            'time': value['time'].toDouble(), // Ensures consistency
          });
        });

        // Sort by highest time survived (descending)
        leaderboard.sort((a, b) => b['time'].compareTo(a['time']));
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching leaderboard data: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
            child: CustomButton(
              text: 'Return to Home',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomeScreen(title: 'Asteroid Game Home Screen')),
                );
              },
              buttonStyle: returnButtonStyle,
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _getLeaderboardData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading leaderboard",
                    style: TextStyle(
                      fontSize: 24, // Adjust the size as needed
                      fontFamily: 'Orbitron',
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "No leaderboard data available",
                    style: TextStyle(
                      fontSize: 24, // Adjust the size as needed
                      fontFamily: 'Orbitron',
                      color: Colors.white, // Set text color to white
                    ),
                  ),
                );
              }

              final leaderboard = snapshot.data!;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400), // Adjust width as needed
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(178),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Leaderboard",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(flex: 1, child: Text("Rank", style: TextStyle(color: Colors.white))),
                            Expanded(flex: 3, child: Text("Name", style: TextStyle(color: Colors.white))),
                            Expanded(flex: 2, child: Text("Time (s)", style: TextStyle(color: Colors.white))),
                          ],
                        ),
                        const Divider(color: Colors.white),
                        ...leaderboard.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(data['name'], style: TextStyle(color: Colors.white)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(data['time'].toStringAsFixed(2), style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}