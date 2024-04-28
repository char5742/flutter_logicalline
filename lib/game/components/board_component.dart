import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter_logicalline/game/components/cell_component.dart';
import 'package:flutter_logicalline/game/components/piece_component.dart';

class BoardComponent extends RectangleComponent {
  /// ボードが持つセルのリスト
  final List<CellComponent> cells;
  final List<CellComponent> initCells;
  static const paddingSize = 5;

  BoardComponent({
    required this.cells,
    required this.initCells,
  }) : assert(cells.length == 9, 'cells must be 9') {
    position = Vector2(100, 100);

    size = Vector2.all(300 + paddingSize * 4);
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
    cell
      ..size = cellSize
      ..position = position +
          Vector2(
            cellSize.x * i + (i + 1) * paddingSize,
            cellSize.y * j + (j + 1) * paddingSize,
          )
      ..anchor = anchor;
  }

  void setupInitCells(Vector2 defaultCellSize) {
    for (var i = 0; i < initCells.length; i++) {
      final cell = initCells[i];

      cell
        ..size = Vector2.all(50)
        ..position = position +
            Vector2(
              (defaultCellSize.x * 3 + paddingSize * 4 - 50) * i,
              defaultCellSize.y * 4,
            );
      cell.setPieces(
        defaultCellSize: defaultCellSize,
        onStartPiece: onStartPiece,
        onUpdatePiece: onUpdatePiece,
        onDragEndPiece: onDragEndPiece,
      );
    }
  }

  Function(DragStartEvent) onStartPiece(
    CellComponent cell,
    Vector2 cellSize,
    PieceComponent piece,
  ) {
    return (DragStartEvent event) {
      final abovePieces = cell.abovePieceOf(piece);
      abovePieces?.onDragStart(event);
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
      final abovePiec = cell.abovePieceOf(piece);
      abovePiec?.onDragUpdate(event);
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
      final abovePieces = cell.abovePieceOf(piece);

      for (final c in cells) {
        if (c.containsPosition(piece.position)) {
          // もし同じセルである場合は、位置を戻すだけ
          if (c == cell) {
            cell.alignPieces();
            isNotMoved = false;
            break;
          }

          // もし違うセルに移動する場合は、元のセルからピースを削除し、新しいセルに追加する
          cell.removePiece(piece);
          c.addPiece(
            piece,
            onDragEndCallback: onDragEndPiece(c, cellSize, piece),
            onDragStartCallback: onStartPiece(c, cellSize, piece),
            onDragUpdateCallback: onUpdatePiece(c, cellSize, piece),
          );

          isNotMoved = false;
          break;
        }
      }

      // もし他のセルに移動しなかった場合は、元のセルに戻す
      if (isNotMoved) {
        cell.alignPieces();
      }

      abovePieces?.onDragEnd(event);
    };
  }
}
