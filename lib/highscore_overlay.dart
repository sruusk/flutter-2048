import 'package:flutter/material.dart';
import 'package:flutter_2048/game.dart';

class HighScoreOverlay extends StatefulWidget {
  final List<HighScore> highScores;
  final Function onRestart;

  const HighScoreOverlay({
    required this.highScores,
    required this.onRestart,
    super.key,
  });

  @override
  State<HighScoreOverlay> createState() => _HighScoreOverlayState();
}

class _HighScoreOverlayState extends State<HighScoreOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Colors.orange[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'High Scores',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                for (final highScore in widget.highScores)
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: ListTile(
                        tileColor: Colors.orange[100],
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: Text('Score: ${highScore.score}', style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text('Largest Tile: ${highScore.largestTile}', style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onRestart();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
