import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import '../engine/game_engine.dart';
import '../engine/constants.dart' as C;
import '../ui/board_controller.dart';

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
  GameEngine game;

  /// Difficulty level
  int difficulty;

  /// Whether AI is enabled
  bool enableAI;

  /// The color the human is playing
  String playerColor;

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
      this.enableUserMoves,
      this.difficulty,
      this.enableAI,
      this.playerColor,
      ) {
    game = new GameEngine(this.difficulty);
    boardController?.game = game;
    boardController?.refreshBoard = refreshBoard;
    if (this.enableAI && this.playerColor == 'Black') {
      game.makeAIMove();
    }
  }
}
