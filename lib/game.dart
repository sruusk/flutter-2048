import 'dart:convert';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_2048/world.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Game2048 extends FlameGame with HasKeyboardHandlerComponents {
  static const int gridSize = 4;
  static Vector2 tileSize = Vector2.all(64.0);
  static const double tilePadding = 10.0;
  static Random random = Random();
  List<HighScore> highScores = [];
  HighScore? lastGameScore;

  @override
  Color backgroundColor() => Colors.blueGrey;

  Game2048() : super(world: World2048()) {
    loadHighScores();
  }

  void loadHighScores() {
    SharedPreferences.getInstance().then((prefs) {
      final highScoresJson = prefs.getString('highScores');
      if (highScoresJson != null) {
        highScores = HighScore.fromJsonList(json.decode(highScoresJson));
      }
    });
  }

  void newScore(int score, int largestTile) {
    lastGameScore = HighScore(score: score, largestTile: largestTile);
    highScores.add(lastGameScore!);
    highScores.sort((a, b) => b.score.compareTo(a.score));
    highScores = highScores.take(5).toList();
    saveHighScores();
  }

  void saveHighScores() {
    final highScoresJson = json.encode(HighScore.toJsonList(highScores));
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('highScores', highScoresJson);
    });
  }
}

class HighScore {
  final int score;
  final int largestTile;

  HighScore({required this.score, required this.largestTile});

  static List<HighScore> fromJsonList(List<dynamic> json) {
    return json.map((e) => HighScore.fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<HighScore> highScores) {
    return highScores.map((e) => e.toJson()).toList();
  }

  HighScore.fromJson(Map<String, dynamic> json)
      : score = json['score'],
        largestTile = json['largestTile'];

  Map<String, dynamic> toJson() => {
    'score': score,
    'largestTile': largestTile,
  };

  @override
  String toString() {
    return 'Score: $score, Largest Tile: $largestTile';
  }
}
