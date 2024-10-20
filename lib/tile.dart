import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/game.dart';
import 'package:flutter_2048/world.dart';

class Tile extends PositionComponent with HasWorldReference<World2048>, HasGameReference<Game2048> {
  int value;
  Vector2 gridPosition;
  Offset offset;
  final int gridSize = Game2048.gridSize;
  final double tilePadding = Game2048.tilePadding;
  Vector2 tileSize = Game2048.tileSize;
  bool markedForRemoval = false; // Whether this tile should be removed from the grid in the next update
  bool merged = false; // Whether this tile has been merged with another tile during this move

  Tile({super.position, required this.value, required this.offset, required this.gridPosition}) : super(size: Game2048.tileSize);

  static Vector2 calculatePosition(Vector2 gridPosition, Vector2 tileSize, double tilePadding, Offset offset) {
    return Vector2(offset.dx, offset.dy) / 2 + gridPosition * (tileSize.x / 2 + tilePadding / 2);
  }

  bool move(int dx, int dy) {
    bool moved = false;
    int maxLoops = gridSize * gridSize;
    Vector2 newGridPosition = gridPosition.clone();

    while (true) {
      maxLoops--;
      if (maxLoops <= 0) {
        debugPrint('Max loops reached');
        break;
      }
      final newX = newGridPosition.x + dx;
      final newY = newGridPosition.y + dy;

      // Check if the new position is within the grid boundaries
      if (newX < 0 || newX >= gridSize || newY < 0 || newY >= gridSize) {
        break;
      }

      // Check if the target position is occupied by another tile
      final targetTile = world.tiles.firstWhere(
        (tile) => tile.gridPosition.x == newX && tile.gridPosition.y == newY && !tile.markedForRemoval,
        orElse: () => Tile(position: Vector2(-1, -1), value: -1, offset: Offset.zero, gridPosition: Vector2(-1, -1)), // Return a dummy tile
      );

      if (targetTile.value != -1) {
        // If the target tile has the same value and hasn't been merged, merge the tiles
        if (targetTile.value == value && !targetTile.merged) {
          value *= 2;
          merged = true; // Mark the target tile as merged
          newGridPosition = targetTile.gridPosition.clone();
          targetTile.markedForRemoval = true; // Mark this tile for removal
          moved = true;
        }
        break;
      } else {
        newGridPosition = Vector2(newX, newY);
        moved = true;
      }
    }

    if (moved) {
      gridPosition = newGridPosition;
    }

    return moved;
  }

  Future<void> updatePosition() async {
    var moveEffect = MoveEffect.to(
      Tile.calculatePosition(gridPosition, tileSize, tilePadding, world.offset),
      EffectController(duration: world.tileMoveDuration),
    );
    await add(moveEffect);
    await moveEffect.completed;
  }

    Color get color => [
    const Color(0xFFEAE0D5),
    const Color(0xFFEEE4DA),
    const Color(0xFFEDE0C8),
    const Color(0xFFF2B179),
    const Color(0xFFF59563),
    const Color(0xFFF67C5F),
    const Color(0xFFF65E3B),
    const Color(0xFFEDCF72),
    const Color(0xFFEDCC61),
    const Color(0xFFEDC850),
    const Color(0xFFEDC53F),
    const Color(0xFFEDC22E),
  ][(value - 1) % 12];

  // Shadow color is a darker version of the tile color
  Color get shadowColor {
    final hslColor = HSLColor.fromColor(color);
    final lessBrightHslColor = hslColor.withLightness(hslColor.lightness * 0.6);
    return lessBrightHslColor.toColor();
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      position.x,
      position.y,
      size.x,
      size.y
    ).shift(const Offset(-3, -3));
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));


    final shadowRect = rect.shift(const Offset(3, 3));
    final shadowRRect = RRect.fromRectAndRadius(shadowRect, const Radius.circular(10));

    // Draw tile
    canvas.drawRRect(shadowRRect, Paint()..color = shadowColor);
    canvas.drawRRect(rrect, Paint()..color = color);

    final textSpan = TextSpan(
      text: value.toString(),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final paintOffset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, paintOffset);
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'gridPosition': gridPosition.toJson(),
    };
  }

  static Tile fromJson(Map<String, dynamic> json) {
    return Tile(
      value: json['value'],
      gridPosition: Vector2(json['gridPosition']['x'], json['gridPosition']['y']),
      offset: Offset.zero,
    );
  }
}

extension on Vector2 {
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}
