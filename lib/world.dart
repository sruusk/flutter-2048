import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_2048/button.dart';
import 'package:flutter_2048/score_box.dart';
import 'package:flutter_2048/tile.dart';
import 'package:flame_audio/flame_audio.dart';
import 'game.dart';
import 'grid.dart';

class World2048 extends World with HasGameReference<Game2048>, KeyboardHandler, DragCallbacks {
  final gridSize = Game2048.gridSize;
  final tileSize = Game2048.tileSize;
  final tilePadding = Game2048.tilePadding;

  final List<Tile> tiles = [];
  final double tileMoveDuration = 0.1;
  late ScoreBox scoreBox;
  Offset offset = Offset.zero;
  final gameOverIdentifier = "GameOver";
  final highScoreIdentifier = "HighScore";
  int score = 0;
  bool gameOver = false;
  bool moving = false;

  World2048() {
    // Calculate the offset to center the grid
    final gridWidth = gridSize * (tileSize.x + tilePadding) - tilePadding;
    final gridHeight = gridSize * (tileSize.y + tilePadding) - tilePadding;
    final offsetX = gridWidth / 2;
    final offsetY = gridHeight / 2;
    offset = Offset(-offsetX, -offsetY);
  }

  @override
  void onLoad() {
    super.onLoad();
    debugPrint('Loading world');

    add(Grid(gridSize: gridSize, tileSize: tileSize.x, tilePadding: tilePadding, offset: offset));
    addTile();
    addTile();
    add(KeyboardListenerComponent(
      keyUp: {
        LogicalKeyboardKey.arrowUp: (keysPressed) {
          debugPrint('Up');
          move(0, -1);
          return true;
        },
        LogicalKeyboardKey.arrowDown: (keysPressed) {
          debugPrint('Down');
          move(0, 1);
          return true;
        },
        LogicalKeyboardKey.arrowLeft: (keysPressed) {
          debugPrint('Left');
          move(-1, 0);
          return true;
        },
        LogicalKeyboardKey.arrowRight: (keysPressed) {
          debugPrint('Right');
          move(1, 0);
          return true;
        },
        LogicalKeyboardKey.keyW: (keysPressed) {
          debugPrint('Up');
          move(0, -1);
          return true;
        },
        LogicalKeyboardKey.keyS: (keysPressed) {
          debugPrint('Down');
          move(0, 1);
          return true;
        },
        LogicalKeyboardKey.keyA: (keysPressed) {
          debugPrint('Left');
          move(-1, 0);
          return true;
        },
        LogicalKeyboardKey.keyD: (keysPressed) {
          debugPrint('Right');
          move(1, 0);
          return true;
        },
      }
    ));

    double buttonY = offset.dy + gridSize * (tileSize.x + tilePadding) + 50;

    addButton('Restart', Vector2(70, buttonY), Vector2(100, 50), () {
      debugPrint('Restarting game');
      game.overlays.remove(gameOverIdentifier);
      game.world = World2048();
    });

    addButton('History', Vector2(-70, buttonY), Vector2(100, 50), () {
      game.overlays.add(highScoreIdentifier);
    });

    scoreBox = ScoreBox(
      title: 'Flutter 2048',
      score: score,
      position: Vector2(offset.dx / 2, offset.dy),
      size: Vector2(gridSize * (tileSize.x + tilePadding) - tilePadding, 100),
    );
    add(scoreBox);
  }

  Vector2 dragEvent = Vector2.zero();
  @override
  void onDragStart(DragStartEvent event) {
    dragEvent = Vector2.zero();
  }
  @override
  void onDragUpdate(DragUpdateEvent event) {
    dragEvent += event.delta;
  }
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    const double dragThreshold = 30.0;
    if (dragEvent.length > dragThreshold) {
      if (dragEvent.x.abs() > dragEvent.y.abs()) {
        if (dragEvent.x > 0) {
          move(1, 0);
        } else {
          move(-1, 0);
        }
      } else {
        if (dragEvent.y > 0) {
          move(0, 1);
        } else {
          move(0, -1);
        }
      }
    }
  }

  bool canAddTile() {
    return tiles.length < gridSize * gridSize;
  }

  void addTile() {
    if (!canAddTile()) {
      return;
    }
    final allTilePositions = List.generate(gridSize, (index) => index)
        .expand((x) => List.generate(gridSize, (index) => index).map((y) => Vector2(x.toDouble(), y.toDouble())))
        .toList();
    final occupiedTilePositions = tiles.map((tile) => tile.gridPosition).toList();
    final emptyTilePositions = allTilePositions.where((position) => !occupiedTilePositions.contains(position)).toList();

    final emptyTile = emptyTilePositions[Game2048.random.nextInt(emptyTilePositions.length)];
    final value = Game2048.random.nextDouble() < 0.9 ? 2 : 4;
    final tile = Tile(
      position: Tile.calculatePosition(emptyTile, tileSize, tilePadding, offset),
      value: value,
      offset: offset,
      gridPosition: emptyTile.clone(),
    );

    debugPrint('Adding tile at $emptyTile with value $value');
    tiles.add(tile);
    add(tile);
  }

  void addButton(String label, Vector2 position, Vector2 size, void Function() onTap) {
    final button = Button(
      label,
      size: size,
      position: position,
      onReleased: onTap,
    );
    add(button);
  }

  bool isGameOver() {
    print('Tiles: ${tiles.length} Grid size: ${gridSize * gridSize}');
    if (tiles.length < gridSize * gridSize) {
      return false;
    }

    for (var tile in tiles) {
      final x = tile.gridPosition.x.toInt();
      final y = tile.gridPosition.y.toInt();
      final value = tile.value;

      // Check if there are any adjacent tiles with the same value
      if (x > 0 && tiles.any((t) => t.gridPosition.x.toInt() == x - 1 && t.gridPosition.y.toInt() == y && t.value == value)) {
        return false;
      }
      if (x < gridSize - 1 && tiles.any((t) => t.gridPosition.x.toInt() == x + 1 && t.gridPosition.y.toInt() == y && t.value == value)) {
        return false;
      }
      if (y > 0 && tiles.any((t) => t.gridPosition.x.toInt() == x && t.gridPosition.y.toInt() == y - 1 && t.value == value)) {
        return false;
      }
      if (y < gridSize - 1 && tiles.any((t) => t.gridPosition.x.toInt() == x && t.gridPosition.y.toInt() == y + 1 && t.value == value)) {
        return false;
      }
    }

    return true;
  }

  void move(int dx, int dy) async {
    if (gameOver || moving) {
      return;
    }
    bool moved = false;

    // Reset merged flag for all tiles
    for (var tile in tiles) {
      tile.merged = false;
    }

    // Sort tiles based on the direction of movement
    tiles.sort((a, b) {
      if (dx == 1) return b.gridPosition.x.compareTo(a.gridPosition.x); // Right
      if (dx == -1) return a.gridPosition.x.compareTo(b.gridPosition.x); // Left
      if (dy == 1) return b.gridPosition.y.compareTo(a.gridPosition.y); // Down
      if (dy == -1) return a.gridPosition.y.compareTo(b.gridPosition.y); // Up
      return 0;
    });

    for (var tile in tiles) {
      if (tile.move(dx, dy)) {
        moved = true;
      }
    }

    if (moved) {
      moving = true;
      FlameAudio.play('move.mp3', volume: 0.1);
      List<Future<void>> moveFutures = [];
      for (var tile in tiles) {
        moveFutures.add(tile.updatePosition());
      }
      await Future.wait(moveFutures);
      addTile();

      // Remove tiles after animation
      for (var tile in tiles) {
        if (tile.markedForRemoval) {
          score += tile.value * 2;
          scoreBox.updateScore(score);
          remove(tile);
        }
      }
      tiles.removeWhere((tile) => tile.markedForRemoval);

      if(isGameOver()) {
        debugPrint('Game over with score $score');
        debugPrint('Tiles: ${tiles.length}');
        gameOver = true;
        game.newScore(score, tiles.map((tile) => tile.value).reduce((value, element) => value > element ? value : element));
        game.overlays.add(gameOverIdentifier);
      }
      moving = false;
    }
  }
}
