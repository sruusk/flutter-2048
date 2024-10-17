import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/rendering.dart';
import 'package:flutter/material.dart';

class FlatButton extends ButtonComponent {
  FlatButton(
      String text, {
        super.size,
        super.onReleased,
        super.position,
      }) : super(
    button: ButtonBackground(const Color(0xfffddeb1), text, 5),
    buttonDown: ButtonBackground(const Color(0xffd0c6b6), text, -2),
    anchor: Anchor.center,
  );
}

class ButtonBackground extends PositionComponent with HasAncestor<FlatButton> {
  final _paint = Paint()..style = PaintingStyle.fill;
  final _shadowPaint = Paint()
    ..color = Colors.black.withOpacity(0.2)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  final String text;
  final double shadowLength;

  late double cornerRadius;

  ButtonBackground(Color color, this.text, this.shadowLength) {
    _paint.color = color;
  }

  @override
  void onMount() {
    super.onMount();
    size = ancestor.size;
    cornerRadius = 0.3 * size.y;
    _paint.strokeWidth = 0.05 * size.y;
  }

  late final _background = RRect.fromRectAndRadius(
    size.toRect(),
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
