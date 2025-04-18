import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlameAudio.audioCache.loadAll([
    'Dark Castle A.mp3',
  ]);

  try {
    // Explicitly provide the FirebaseOptions
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDi0WI9I8JldV_YchUF5sDVOG_TBed-tSE",
        appId: "1:465162584247:android:9078794e0ecaf6b4960d32",
        messagingSenderId: "465162584247",
        projectId: "asteroidsdb",
        databaseURL: "https://asteroidsdb-default-rtdb.firebaseio.com/", // Optional, for Realtime Database
      ),
    );
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asteroid Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(title: 'Asteroid Game Home Screen'),
    );
  }
}
