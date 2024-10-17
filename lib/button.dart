import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

class Button extends ButtonComponent {
  Button(
      String text, {
        super.size,
        super.onReleased,
        super.position,
      }) : super(
    button: ButtonBackground(const Color(0xfffddeb1), const Color(0xFFCAB28D), text, 1.5),
    buttonDown: ButtonBackground(const Color(0xffE6C9A1), const Color(0xFFCAB28D), text, -1.5),
    anchor: Anchor.center,
  );
}

class ButtonBackground extends PositionComponent with HasAncestor<Button> {
  final _paint = Paint()..style = PaintingStyle.fill;
  final _shadowPaint = Paint();
  final String text;
  final double shadowLength;

  late double cornerRadius;

  ButtonBackground(Color color, Color shadowColour, this.text, this.shadowLength) {
    _paint.color = color;
    _shadowPaint.color = shadowColour;
  }

  @override
  void onMount() {
    super.onMount();
    size = ancestor.size;
    cornerRadius = 0.2 * size.y;
    _paint.strokeWidth = 0.05 * size.y;
  }

  late final _background = RRect.fromRectAndRadius(
    size.toRect().shift(Offset(-shadowLength, -shadowLength)),
    Radius.circular(cornerRadius),
  );

  late final _backgroundShadow = RRect.fromRectAndRadius(
    size.toRect().shift(Offset(shadowLength, shadowLength)),
    Radius.circular(cornerRadius),
  );

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(_backgroundShadow, _shadowPaint);
    canvas.drawRRect(_background, _paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 0.5 * size.y,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.x - textPainter.width) / 2,
      (size.y - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }
}
