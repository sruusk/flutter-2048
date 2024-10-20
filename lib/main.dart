import 'package:flame/game.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/leaderboard_overlay.dart';
import 'game.dart';
import 'game_over.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        textTheme: const TextTheme(
          bodySmall: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
          bodyLarge: TextStyle(color: Colors.black),
          titleSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.orange[100]),
            foregroundColor: WidgetStateProperty.all(Colors.black),
            elevation: WidgetStateProperty.all(5),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GameWidget(
          game: Game2048(),
          overlayBuilderMap: {
            'Leaderboard': (BuildContext context, Game2048 game) {
              return LeaderboardOverlay(onRestart: () => {
                game.overlays.remove('Leaderboard'),
              }
              );
            },
            'GameOver': (BuildContext context, Game2048 game) {
              return game.lastGameScore != null ? GameOver(
                score: game.lastGameScore,
                close: () {
                  game.overlays.remove('GameOver');
                },
              ) : const Center(
                child: CircularProgressIndicator(),
              );
            },
          },
        ),
      ),
    );
  }
}

class SplashScreenGame extends StatefulWidget {
  const SplashScreenGame({super.key});

  @override
  State<SplashScreenGame> createState() => _SplashScreenGameState();
}

class _SplashScreenGameState extends State<SplashScreenGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlameSplashScreen(
        showBefore: (BuildContext context) {
          return const Padding(
            padding: EdgeInsets.all(60.0),
            child: Image(image: AssetImage('assets/images/lockup_built-w-flutter_wht.png')),
          );
        },
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        ),
      ),
    );
  }
}
