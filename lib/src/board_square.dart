import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';
import 'constants.dart' as C;
import 'board_model.dart';

/// A single square on the chessboard
class BoardSquare extends StatelessWidget {
  /// The square name (a2, d3, e4, etc.)
  final squareName;

  BoardSquare({this.squareName});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BoardModel>(builder: (context, _, model) {
      return Expanded(
        flex: 1,
        child: DragTarget(builder: (context, accepted, rejected) {
          return model.game.get(squareName) != null
              ? Draggable(
            child: _getImageToDisplay(size: model.size / 8, model: model),
            feedback: _getImageToDisplay(
                size: (1.2 * (model.size / 8)), model: model),
            onDragCompleted: () {},
            data: [
              squareName,
              model.game.get(squareName).type,
              model.game.get(squareName).color,
            ],
          )
              : Container();
        }, onWillAccept: (willAccept) {
          return model.enableUserMoves ? true : false;
        }, onAccept: (List moveInfo) {
          // A way to check if move occurred.
          Color moveColor = model.game.state.turn;
          model.game.move({"from": moveInfo[0], "to": squareName});

          if (model.game.state.turn != moveColor) {
            model.onMove(
                moveInfo[1] == "P" ? squareName : moveInfo[1].toString() + squareName);
            model.refreshBoard();
            model.game.makeAIMove();
          }
          model.refreshBoard();
        }),
      );
    });
  }

  /// Get image to display on square
  Widget _getImageToDisplay({double size, BoardModel model}) {
    Widget imageToDisplay = Container();

    if (model.game.get(squareName) == null) {
      return Container();
    }

    Color piece = model.game
        .get(squareName)
        .color;
    if (piece == C.WHITE) {
      imageToDisplay = WhitePawn(size: size);
    } else if (piece == C.BLACK) {
      imageToDisplay = BlackPawn(size: size);
    }

    return imageToDisplay;
  }
}