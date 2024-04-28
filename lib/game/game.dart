import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/cell_component.dart';
import 'package:flutter_logicalline/game/components/game_state_component.dart';

class LogicalLineGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.white;

  LogicalLineGame()
      : super(
          camera: CameraComponent.withFixedResolution(width: 520, height: 600),
        );

  late final GameStateComponent state;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    state = GameStateComponent();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(state);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 勝敗判定
    final winner = whichColorWon(state.board.cells);

    state.result.setWinner(winner);
  }

  PieceColor? whichColorWon(List<CellComponent> cellList) {
    /**
    縦、横、斜めいずれかの列で3回所有権が続いた時に勝者が決定する
    セルの情報を用意する
                  036
                  147
                  258
    横:
    インデックス番号が3ずつ増える

    縦:
    インデックス番号が1ずつ増える

    斜め:
    0,4,8　4ずつ増える
    2,4,6 2ずつ増える
    */

    final ownershipList = cellList.map((e) => e.getCellOwnership()).toList();

    for (var i = 0; i < 3; i++) {
      // 横の確認
      if (ownershipList[0 + i] != null &&
          ownershipList[0 + i] == ownershipList[3 + i] &&
          ownershipList[3 + i] == ownershipList[6 + i]) {
        return ownershipList[0 + i];
      }
      // 縦の確認
      if (ownershipList[0 + i * 3] != null &&
          ownershipList[0 + i * 3] == ownershipList[1 + i * 3] &&
          ownershipList[1 + i * 3] == ownershipList[2 + i * 3]) {
        return ownershipList[0 + i * 3];
      }
    }
    // 斜めの確認
    if (ownershipList[0] != null &&
        ownershipList[0] == ownershipList[4] &&
        ownershipList[4] == ownershipList[8]) {
      return ownershipList[0];
    }
    if (ownershipList[2] != null &&
        ownershipList[2] == ownershipList[4] &&
        ownershipList[4] == ownershipList[6]) {
      return ownershipList[2];
    }
    return null;
  }
}
