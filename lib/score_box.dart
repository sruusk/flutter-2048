import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/game.dart';

class ScoreBox extends PositionComponent {
  final String title;
  int score;

  ScoreBox({
    required this.title,
    required this.score,
    super.position,
    super.size,
  });

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.orange[100]!
      ..style = PaintingStyle.fill;

    // Draw the large background rectangle with rounded corners
    final backgroundRectShadow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        position.x + 3,
        position.y + 3,
        size.x,
        size.y,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(backgroundRectShadow, paint..color = const Color(0xFFCAB28D));
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        position.x,
        position.y,
        size.x,
        size.y,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(backgroundRect, paint..color = Colors.orange[100]!);

    // Draw the score box
    final cellRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        position.x + size.x - Game2048.mainWidth + 80,
        position.y + size.y - 50,
        Game2048.mainWidth - 90,
        40,
      ),
      const Radius.circular(10),
    );

    // Draw inset shadow
    canvas.drawRRect(
      cellRect.shift(const Offset(-3, -3)),
      paint..color = Colors.black.withOpacity(0.2),
    );

    // Draw cell
    canvas.drawRRect(cellRect, paint..color = Colors.white);

    // Draw title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();

    final titleOffset = Offset(
      position.x + (size.x - titlePainter.width) / 2,
      position.y + 10,
    );
    titlePainter.paint(canvas, titleOffset);

    // Draw score label
    final scoreLabelPainter = TextPainter(
      text: const TextSpan(
        text: 'Score:',
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    scoreLabelPainter.layout();

    final scoreLabelOffset = Offset(
      position.x + 10,
      position.y + size.y - 45,
    );
    scoreLabelPainter.paint(canvas, scoreLabelOffset);

    // Draw score
    final scorePainter = TextPainter(
      text: TextSpan(
        text: score.toString(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();

    final scoreOffset = Offset(
      position.x + size.x - 20 - scorePainter.width,
      position.y + size.y - 50,
    );
    scorePainter.paint(canvas, scoreOffset);
  }

  void updateScore(int newScore) {
    score = newScore;
  }
}
