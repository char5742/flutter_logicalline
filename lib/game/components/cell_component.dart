import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/game_state_component.dart';
import 'package:flutter_logicalline/game/components/piece_component.dart';

class CellComponent extends RectangleComponent {
  /// セルが持つピースのリスト
  final List<PieceComponent> _pieces;

  CellComponent({
    required List<PieceComponent> pieces,
    super.position,
    super.size,
    super.anchor,
    super.key,
  })  : _pieces = pieces,
        super(
          paint: Paint()..color = Colors.blueGrey,
          priority: 1,
        );

  /// セルにピースをセットする
  void setPieces({
    required Vector2 defaultCellSize,
    required Function(DragStartEvent) Function(
            CellComponent, Vector2, PieceComponent)
        onStartPiece,
    required Function(DragUpdateEvent) Function(
            CellComponent, Vector2, PieceComponent)
        onUpdatePiece,
    required Function(DragEndEvent) Function(
            CellComponent, Vector2, PieceComponent)
        onDragEndPiece,
  }) {
    for (final piece in _pieces) {
      final targetIndex = _pieces.indexOf(piece);
      final belowSameColorLength = _pieces
          .sublist(0, targetIndex)
          .where((p) => p.pieceColor == piece.pieceColor)
          .length;
      piece
        ..onDragStartCallback = onStartPiece(this, defaultCellSize, piece)
        ..onDragUpdateCallback = onUpdatePiece(this, defaultCellSize, piece)
        ..onDragEndCallback = onDragEndPiece(this, defaultCellSize, piece)
        ..position = position +
            Vector2(
              size.x / 2,
              size.y / 1.5 - belowSameColorLength * piece.size.y / 2,
            )
        ..anchor = Anchor.center;
    }
  }

  /// セルにあるピースを整列させる
  void alignPieces() {
    for (final piece in _pieces) {
      final targetIndex = _pieces.indexOf(piece);
      final belowSameColorLength = _pieces
          .sublist(0, targetIndex)
          .where((p) => p.pieceColor == piece.pieceColor)
          .length;
      piece.position = position +
          Vector2(
            size.x / 2,
            size.y / 1.5 - belowSameColorLength * piece.size.y / 2,
          );
    }
  }

  /// セルにピースを追加する
  void addPiece(
    PieceComponent piece, {
    required Function(DragEndEvent) onDragEndCallback,
    required Function(DragStartEvent) onDragStartCallback,
    required Function(DragUpdateEvent) onDragUpdateCallback,
  }) {
    final sameColorLength =
        _pieces.where((p) => p.pieceColor == piece.pieceColor).length;

    piece
      ..position = position +
          Vector2(
            size.x / 2,
            size.y / 1.5 - sameColorLength * piece.size.y / 2,
          )
      ..anchor = piece.pieceColor == PieceColor.white
          ? Anchor.topRight
          : Anchor.bottomLeft
      ..onDragEndCallback = onDragEndCallback
      ..onDragStartCallback = onDragStartCallback
      ..onDragUpdateCallback = onDragUpdateCallback;
    _pieces.add(piece);
  }

  void removePiece(PieceComponent piece) {
    _pieces.remove(piece);
  }

  /// セルに乗っているピースの上にあるピースを返す
  PieceComponent? abovePieceOf(PieceComponent piece) {
    final targetIndex = _pieces.indexOf(piece);
    final abovePieces = _pieces
        .sublist(targetIndex + 1)
        .where((element) => element.pieceColor == piece.pieceColor);
    return abovePieces.firstOrNull;
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
  PieceColor? getCellOwnership() {
    // 白と黒のピースをそれぞれリストに振り分ける
    final whitePieceList =
        _pieces.where((e) => e.pieceColor == PieceColor.white).toList();
    final blackPieceList =
        _pieces.where((e) => e.pieceColor == PieceColor.black).toList();

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

  /// 指定した位置がセル内に含まれるかどうかを返す
  bool containsPosition(Vector2 position) {
    return size.x > position.x - this.position.x &&
        size.y > position.y - this.position.y;
  }
}
