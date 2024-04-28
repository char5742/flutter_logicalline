import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/game_state_component.dart';

/// 円柱を斜めから見たような形状のコンポーネント
class PieceComponent extends CustomPainterComponent with DragCallbacks {
  ///コマの色。白or黒
  final PieceColor pieceColor;

  /// コマの数字
  final int pieceNumber;
  bool isReversed;
  final defaultPriority = 10;

  late Function(DragStartEvent) onDragStartCallback;
  late Function(DragUpdateEvent) onDragUpdateCallback;
  late Function(DragEndEvent) onDragEndCallback;

  PieceComponent({
    required this.pieceColor,
    required this.pieceNumber,
    this.isReversed = false,
    super.anchor,
    super.angle,
    super.position,
  }) : assert(pieceNumber >= 0 && pieceNumber <= 10) {
    painter = _CylinderPainter(
      pieceColor: pieceColor,
      pieceNumber: pieceNumber,
      isReversed: isReversed,
    );
    size = Vector2(40, 16);
    priority = defaultPriority;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // ドラッグ中は他のコンポーネントよりも優先度を高くする
    priority += 1;
    onDragStartCallback(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    onDragUpdateCallback(event);
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // ドラッグが終了したら優先度を元に戻す
    priority = defaultPriority;
    onDragEndCallback(event);
  }
}

class _CylinderPainter extends CustomPainter {
  final PieceColor pieceColor;

  final int pieceNumber;
  final bool isReversed;
  _CylinderPainter({
    required this.pieceColor,
    required this.pieceNumber,
    required this.isReversed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = pieceColor == PieceColor.black ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = pieceColor == PieceColor.black ? Colors.white : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // 下の楕円
    final bottomOval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + size.height / 3),
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(bottomOval, fillPaint);
    canvas.drawOval(bottomOval, strokePaint);
    // 上の楕円
    final topOval = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 3),
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(topOval, fillPaint);
    canvas.drawOval(topOval, strokePaint);

    // 左側の線
    final topOvalLeft = Offset(topOval.left, topOval.center.dy);
    final bottomOvalLeft = Offset(bottomOval.left, bottomOval.center.dy);
    canvas.drawLine(topOvalLeft, bottomOvalLeft, strokePaint);

    // 右側の線
    final topOvalRight = Offset(topOval.right, topOval.center.dy);
    final bottomOvalRight = Offset(bottomOval.right, bottomOval.center.dy);
    canvas.drawLine(topOvalRight, bottomOvalRight, strokePaint);

    // 反転している場合はピースの番号を描画しない
    if (isReversed) {
      return;
    }

    // ピースの番号を描画
    final textPainter = TextPainter(
      text: TextSpan(
        text: pieceNumber.toString(),
        style: TextStyle(
          color: pieceColor == PieceColor.black ? Colors.white : Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2 - 2.0,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
