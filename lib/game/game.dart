import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/board_component.dart';
import 'package:flutter_logicalline/game/components/piece_component.dart';

class LogicalLineGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.white;

  late final BoardComponent board;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final whitePieces = [
      ...List.generate(
        5,
        (index) => PieceComponent(
          pieceColor: PieceColor.white,
          pieceNumber: index * 2 + 1,
        ),
      ),
      PieceComponent(
        pieceColor: PieceColor.white,
        pieceNumber: 5,
      ),
    ];
    final blackPieces = List.generate(
      6,
      (index) => PieceComponent(
        pieceColor: PieceColor.black,
        pieceNumber: index * 2,
      ),
    );

    whitePieces.shuffle();
    blackPieces.shuffle();

    board = BoardComponent(
      initCells: [
        CellComponent(
          pieces: whitePieces,
        ),
        CellComponent(
          pieces: blackPieces,
        ),
      ],
      cells: List.generate(
        9,
        (index) => CellComponent(
          pieces: [],
        ),
      ),
    );
    await add(board);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 勝敗判定
    // board.cells
    final winner = whichColorWon(board.cells);
    print(winner);
  }

  /// セルの所有者を返す
  ///
  /// if ピースが一つもない場合
  /// nullを返す
  ///
  /// if 一つのセルに白と黒のpieceがあった場合
  /// 1. 高さの比較　lengthの出力が大きい方が所有権を持つ
  /// 2. 数字の比較　もし高さが同じ場合数字が大きい方が所有権を持つ
  ///
  /// if 一つのセルにどちらか一方のpieceがあったばあい
  /// 1. 暫定でそのpieceが所有権を持つ
  PieceColor? getCellOwnership(CellComponent cell) {
    // 白と黒のピースをそれぞれリストに振り分ける
    final whitePieceList =
        cell.pieces.where((e) => e.pieceColor == PieceColor.white).toList();
    final blackPieceList =
        cell.pieces.where((e) => e.pieceColor == PieceColor.black).toList();

    final whiteHeight = whitePieceList.length;
    final blackHeight = blackPieceList.length;

    // どちらもない場合は所有者なし
    if (whiteHeight == 0 && blackHeight == 0) {
      return null;
    }
    // 高さの比較　lengthの出力が大きい方が所有権を持つ
    if (whiteHeight != blackHeight) {
      return whiteHeight > blackHeight ? PieceColor.white : PieceColor.black;
    }
    // 数字の比較　もし高さが同じ場合数字が大きい方が所有権を持つ
    final whiteNumber = whitePieceList.last.pieceNumber;
    final blackNumber = blackPieceList.last.pieceNumber;

    return whiteNumber > blackNumber ? PieceColor.white : PieceColor.black;
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

    final ownershipList = cellList.map(getCellOwnership).toList();

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
