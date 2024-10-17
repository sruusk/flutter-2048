import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_2048/world.dart';

class Game2048 extends FlameGame with HasKeyboardHandlerComponents {
  static const int gridSize = 4;
  static Vector2 tileSize = Vector2.all(64.0);
  static const double tilePadding = 10.0;
  static Random random = Random();

  @override
  Color backgroundColor() => Colors.blueGrey;

  Game2048() : super(world: World2048());

}
