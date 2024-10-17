import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/game.dart';

class Grid extends Component with HasGameReference<Game2048> {
  final int gridSize = Game2048.gridSize;
  final double tileSize = Game2048.tileSize.x;
  final double tilePadding = Game2048.tilePadding;
  final double borderSize = Game2048.tilePadding; // Size of the border around the grid
  final double shadowDepth = 4; // Depth of the shadow
  final Offset offset; // Offset to center the grid

  Grid({
    required this.offset,
  });

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.orange[100]!
      ..style = PaintingStyle.fill;

    // Draw the large background rectangle with rounded corners
    final backgroundRectShadow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - borderSize + shadowDepth,
        offset.dy - borderSize + shadowDepth,
        gridSize * (tileSize + tilePadding) - tilePadding + 2 * borderSize,
        gridSize * (tileSize + tilePadding) - tilePadding + 2 * borderSize,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(backgroundRectShadow, paint..color = const Color(0xFFCAB28D));
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - borderSize,
        offset.dy - borderSize,
        gridSize * (tileSize + tilePadding) - tilePadding + 2 * borderSize,
        gridSize * (tileSize + tilePadding) - tilePadding + 2 * borderSize,
      ),
      const Radius.circular(15),
    );
    canvas.drawRRect(backgroundRect, paint..color = Colors.orange[100]!);

    // Draw the smaller rectangles for each cell with inset shadows and rounded corners
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final cellRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            offset.dx + i * (tileSize + tilePadding),
            offset.dy + j * (tileSize + tilePadding),
            tileSize,
            tileSize,
          ),
          const Radius.circular(10),
        );

        // Draw inset shadow
        canvas.drawRRect(
          cellRect.shift(Offset(-shadowDepth, -shadowDepth)),
          paint..color = Colors.black.withOpacity(0.2),
        );

        // Draw cell
        canvas.drawRRect(cellRect, paint..color = Colors.white);
      }
    }
  }
}
