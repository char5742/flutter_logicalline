import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter_logicalline/game/components/board_component.dart';
import 'package:flutter_logicalline/game/components/cell_component.dart';
import 'package:flutter_logicalline/game/components/piece_component.dart';
import 'package:flutter_logicalline/game/components/result_component.dart';

/// セルの状態
///
/// リストのより後ろにあるピースほど上に表示される
typedef Cell = ({
  List<Piece> blackPieces,
  List<Piece> whitePieces,
});

enum PieceColor {
  black,
  white,
}

typedef Piece = ({
  PieceColor pieceColor,
  int pieceNumber,
});

class GameStateComponent extends Component {
  late final BoardComponent board;

  late final ResultComponent result;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    final whitePieces = [
      ...List.generate(
        5,
        (index) => (
          pieceColor: PieceColor.white,
          pieceNumber: index * 2 + 1,
        ),
      ),
      (
        pieceColor: PieceColor.white,
        pieceNumber: 5,
      ),
    ];
    final blackPieces = List.generate(
      6,
      (index) => (
        pieceColor: PieceColor.black,
        pieceNumber: index * 2,
      ),
    );

    whitePieces.shuffle();
    blackPieces.shuffle();

    final cells = List.generate(
      9,
      (index) => (
        whitePieces: <Piece>[],
        blackPieces: <Piece>[],
      ),
    );
    final initCell = (
      whitePieces: whitePieces,
      blackPieces: blackPieces,
    );

    final whitePieceCompoents = initCell.whitePieces
        .map(
          (e) => PieceComponent(
            pieceColor: e.pieceColor,
            pieceNumber: e.pieceNumber,
          ),
        )
        .toList();

    final blackPieceCompoents = initCell.blackPieces
        .map(
          (e) => PieceComponent(
            pieceColor: e.pieceColor,
            pieceNumber: e.pieceNumber,
          ),
        )
        .toList();

    blackPieceCompoents.forEach(add);
    whitePieceCompoents.forEach(add);

    board = BoardComponent(
      initCells: [
        CellComponent(
          pieces: whitePieceCompoents,
        ),
        CellComponent(
          pieces: blackPieceCompoents,
        ),
      ],
      cells: cells
          .map(
            (e) => CellComponent(
              pieces: [
                ...e.whitePieces.map(
                  (e) => PieceComponent(
                    pieceColor: e.pieceColor,
                    pieceNumber: e.pieceNumber,
                  ),
                ),
                ...e.blackPieces.map(
                  (e) => PieceComponent(
                    pieceColor: e.pieceColor,
                    pieceNumber: e.pieceNumber,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    )
      ..cells.forEach(add)
      ..initCells.forEach(add);

    add(board);
    result = ResultComponent();
    add(result);
  }
}
