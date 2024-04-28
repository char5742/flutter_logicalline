import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/game_state_component.dart';

class ResultComponent extends TextComponent {
  
  ResultComponent()
      : super(
          text: '',
          size: Vector2.all(30),
          position: Vector2(100, 0),
          priority: 1000,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontFamily: 'DotGothic16',
            ),
          ),
        );

  void setWinner(PieceColor? winner) {
    text = winner == null ? '' : '${winner.toString().split('.').last}の勝ち';
  }
}
