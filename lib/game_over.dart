import 'package:flutter/material.dart';
import 'package:flutter_2048/game.dart';

class GameOver extends StatelessWidget {
  final HighScore? score;
  final Function close;

  const GameOver({super.key,
    required this.score,
    required this.close,
  });

  @override
  Widget build(BuildContext context) {
    if(score == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Center(
      child: Card(
        color: Colors.blueGrey.withAlpha(250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Game Over!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Text(
                'Score: ${score!.score}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Largest Tile: ${score!.largestTile}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  close();
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
