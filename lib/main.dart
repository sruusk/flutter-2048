import 'package:flame/game.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreenGame(),
      theme: ThemeData.dark(),
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
            padding: EdgeInsets.all(30.0),
            child: Image(image: AssetImage('assets/images/lockup_built-w-flutter_wht.png')),
          );
        },
        // showAfter: (BuildContext context) {
        //   return Padding(
        //     padding: const EdgeInsets.all(30.0),
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         Text(
        //           'How to play',
        //           style: Theme.of(context).textTheme.headlineSmall,
        //         ),
        //
        //       ],
        //     )
        //   );
        // },
        theme: FlameSplashTheme.dark,
        onFinish: (context) => Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        ),
      ),
    );
  }
}
