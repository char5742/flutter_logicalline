import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_logicalline/game/components/piece_component.dart';

class BoardComponent extends RectangleComponent {
  /// ボードが持つセルのリスト
  final List<CellComponent> cells;
  final List<CellComponent> initCells;

  BoardComponent({
    required this.cells,
    required this.initCells,
  }) : assert(cells.length == 9, 'cells must be 9') {
    position = Vector2(100, 100);
    const paddingSize = 5;
    size = Vector2.all(300 + paddingSize * 3);
    anchor = Anchor.topLeft;
    paint = BasicPalette.black.paint();
    priority = 0;
  }

  @override
  void onLoad() {
    super.onLoad();
    final cellSize = Vector2.all(100);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        final cell = cells[i * 3 + j];
        setupCell(cell, cellSize, i, j);
      }
    }
    setupInitCells(cellSize);
  }

  /// セルの位置とサイズを設定し、セルに含まれるピースを配置する
  void setupCell(CellComponent cell, Vector2 cellSize, int i, int j) {
    add(
      cell
        ..size = cellSize
        ..position = Vector2(
          position.x + cellSize.x * (i - 1) + i * 5,
          position.y + cellSize.y * (j - 1) + j * 5,
        )
        ..anchor = anchor,
    );
  }

  void setupInitCells(Vector2 defaultCellSize) {
    for (var i = 0; i < initCells.length; i++) {
      final cell = initCells[i];
      add(
        cell
          ..size = Vector2.all(50)
          ..position = Vector2(
            position.x + defaultCellSize.x * 3 * i - defaultCellSize.x,
            position.y + defaultCellSize.y * 4,
          )
          ..anchor = anchor,
      );
      final cellPosition = cell.position;
      final pieceCount = <PieceColor, int>{
        PieceColor.white: 0,
        PieceColor.black: 0,
      };
      final cellSize = cell.size;
      for (final piece in cell.pieces) {
        final count = pieceCount[piece.pieceColor]!;

        add(
          piece
            ..onDragStartCallback = onStartPiece(cell, defaultCellSize, piece)
            ..onDragUpdateCallback = onUpdatePiece(cell, defaultCellSize, piece)
            ..onDragEndCallback = onDragEndPiece(cell, defaultCellSize, piece)
            ..position = cellPosition +
                Vector2(
                  cellSize.x / 2,
                  cellSize.y / 1.5 - count * piece.size.y / 2,
                )
            ..anchor = Anchor.center,
        );

        pieceCount[piece.pieceColor] = count + 1;
      }
    }
  }

  Function(DragStartEvent) onStartPiece(
    CellComponent cell,
    Vector2 cellSize,
    PieceComponent piece,
  ) {
    return (DragStartEvent event) {
      final targetIndex = cell.pieces.indexOf(piece);

      final abovePieces = cell.pieces
          .sublist(targetIndex + 1)
          .where((element) => element.pieceColor == piece.pieceColor);
      abovePieces.firstOrNull?.onDragStart(event);
    };
  }

  /// ピースがドラッグされたときに、ピースが他のセルに移動する処理を行う
  ///
  /// この処理は、上に乗っているピースのonDragUpdateまで呼び出す
  Function(DragUpdateEvent) onUpdatePiece(
    CellComponent cell,
    Vector2 cellSize,
    PieceComponent piece,
  ) {
    return (DragUpdateEvent event) {
      final targetIndex = cell.pieces.indexOf(piece);

      final abovePieces = cell.pieces
          .sublist(targetIndex + 1)
          .where((element) => element.pieceColor == piece.pieceColor);

      abovePieces.firstOrNull?.onDragUpdate(event);
    };
  }

  /// ピースがドラッグされたときに、ピースが他のセルに移動する処理を行う
  Function(DragEndEvent) onDragEndPiece(
    CellComponent cell,
    Vector2 cellSize,
    PieceComponent piece,
  ) {
    return (DragEndEvent event) {
      var isNotMoved = true;

      final targetIndex = cell.pieces.indexOf(piece);

      final abovePieces = cell.pieces
          .sublist(targetIndex + 1)
          .where((element) => element.pieceColor == piece.pieceColor);

      for (final c in cells) {
        if (c.containsPosition(piece.position)) {
          // もし同じセルである場合は、位置を戻すだけ
          if (c == cell) {
            final targetIndex = cell.pieces.indexOf(piece);
            final belowSameColorLength = cell.pieces
                .sublist(0, targetIndex)
                .where((p) => p.pieceColor == piece.pieceColor)
                .length;
            piece.position = c.position +
                Vector2(
                  cellSize.x / 2,
                  cellSize.y / 1.5 - belowSameColorLength * piece.size.y / 2,
                );
            isNotMoved = false;
            break;
          }

          // もし違うセルに移動する場合は、元のセルからピースを削除し、新しいセルに追加する
          cell.pieces.remove(piece);
          final sameColorLength =
              c.pieces.where((p) => p.pieceColor == piece.pieceColor).length;

          piece
            ..position = c.position +
                Vector2(
                  cellSize.x / 2,
                  cellSize.y / 1.5 - sameColorLength * piece.size.y / 2,
                )
            // TODO(Char5742): initCellsの場合の処理がない
            ..anchor = piece.pieceColor == PieceColor.white
                ? Anchor.topRight
                : Anchor.bottomLeft
            ..onDragEndCallback = onDragEndPiece(c, cellSize, piece)
            ..onDragStartCallback = onStartPiece(c, cellSize, piece)
            ..onDragUpdateCallback = onUpdatePiece(c, cellSize, piece);
          c.pieces.add(piece);
          isNotMoved = false;
          break;
        }
      }

      // もし他のセルに移動しなかった場合は、元のセルに戻す
      if (isNotMoved) {
        final targetIndex = cell.pieces.indexOf(piece);
        final belowSameColorLength = cell.pieces
            .sublist(0, targetIndex)
            .where((p) => p.pieceColor == piece.pieceColor)
            .length;
        piece.position = cell.position +
            Vector2(
              cellSize.x / 2,
              cellSize.y / 1.5 - belowSameColorLength * piece.size.y / 2,
            );
      }

      abovePieces.firstOrNull?.onDragEnd(event);
    };
  }
}

extension on CellComponent {
  /// 指定した位置がセル内に含まれるかどうかを返す
  bool containsPosition(Vector2 position) {
    return size.x > position.x - this.position.x &&
        size.y > position.y - this.position.y;
  }
}

class CellComponent extends RectangleComponent {
  /// セルが持つピースのリスト
  final List<PieceComponent> pieces;

  CellComponent({
    required this.pieces,
    super.position,
    super.size,
    super.anchor,
    super.key,
  }) : super(
          paint: Paint()..color = Colors.blueGrey,
          priority: 1,
        );
}

/**
  cellComponent: 
  9個のセルをリストに入れる
  先に置かれたピースの色によって後続のピースの配置を調整する
*/
