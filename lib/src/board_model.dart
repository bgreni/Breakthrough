import 'dart:ui';
import 'package:scoped_model/scoped_model.dart';
import 'game_engine.dart';
import 'constants.dart' as C;
import 'board_controller.dart';

typedef Null MoveCallback(String moveNotation);
typedef Null OnWinCallBack(String string);

class BoardModel extends Model {
  /// The size of the board (The board is a square)
  double size;

  /// Callback for when a move is made
  MoveCallback onMove;

  /// Callback for when a player is checkmated
  OnWinCallBack onWin;

  /// If the white side of the board is towards the user
  bool whiteSideTowardsUser;

  /// The controller for programmatically making moves
  BoardController boardController;

  /// User moves can be enabled or disabled by this property
  bool enableUserMoves;

  /// Creates a logical game
  GameEngine game = new GameEngine();

  /// Refreshes board
  void refreshBoard() {
    if (game.gameOver) {
      onWin(game.state.turn == C.WHITE ? "white" : "black");
      game.reset();
    }
    notifyListeners();
  }

  BoardModel(
      this.size,
      this.onMove,
      this.onWin,
      this.whiteSideTowardsUser,
      this.boardController,
      this.enableUserMoves) {
    boardController?.game = game;
    boardController?.refreshBoard = refreshBoard;
  }
}
