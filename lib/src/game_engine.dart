import 'dart:math';

import 'package:flutter/material.dart';
import 'constants.dart' as C;
import 'AI.dart';

class GameEngine {
  static const Color BLACK = C.BLACK;
  static const Color WHITE = C.WHITE;

  static const Map<String, String> FLAGS = const {
    'NORMAL': 'n',
    'CAPTURE' : 'c'
  };

  static const int BITS_NORMAL = 1;
  static const int BITS_CAPTURE = 2;

  static const Map SQUARES = const {
    'a8':   0, 'b8':   1, 'c8':   2, 'd8':   3, 'e8':   4, 'f8':   5, 'g8':   6, 'h8':   7,
    'a7':  8, 'b7':  9, 'c7':  10, 'd7':  11, 'e7':  12, 'f7':  13, 'g7':  14, 'h7':  15,
    'a6':  16, 'b6':  17, 'c6':  18, 'd6':  19, 'e6':  20, 'f6':  21, 'g6':  22, 'h6':  23,
    'a5':  24, 'b5':  25, 'c5':  26, 'd5':  27, 'e5':  28, 'f5':  29, 'g5':  30, 'h5':  31,
    'a4':  32, 'b4':  33, 'c4':  34, 'd4':  35, 'e4':  36, 'f4':  37, 'g4':  38, 'h4':  39,
    'a3':  40, 'b3':  41, 'c3':  42, 'd3':  43, 'e3':  44, 'f3':  45, 'g3':  46, 'h3':  47,
    'a2':  48, 'b2':  49, 'c2':  50, 'd2':  51, 'e2': 52, 'f2': 53, 'g2': 54, 'h2': 55,
    'a1': 56, 'b1': 57, 'c1': 58, 'd1': 59, 'e1': 60, 'f1': 61, 'g1': 62, 'h1': 63
  };

  State state =  new State(new Board(), WHITE);
  List<State> history = [];
  bool gameOver = false;
  AI ai = RandomAI();


  GameEngine() {
    state.board.initBoard();
  }

  bool applyMove(Move move) {
    return state.board.apply(move);
  }

  void reset() {
    State state =  new State(new Board(), WHITE);
    List<State> history = [];
    bool gameOver = false;
  }

  Piece get(String square) {
    int boardInt = state.board.board[SQUARES[square]];
    if (boardInt == 0) return null;
    return Piece(Piece.intToColor(boardInt));
  }


  bool move(move) {
    Move m = null;
    if (move is Map) {
      int from = SQUARES[move['from']];
      int to = SQUARES[move['to']];
      m = new Move(state.turn, from, to, 0);
    } else if (move is Move) {
      m = move;
    }

    if (m == null || !isLegalMove(m)) return false;
    make_move(m);
    if (isWin()) {
      this.gameOver = true;
    }
    reverseTurn();
    return true;
  }

  bool isWin() {
    return state.board.topRow().contains(1) || state.board.bottomRow().contains(2);
  }

  List<Move> getLegalMoves(Color toPlay) {
    List<Move> legalMoves = [];
    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      if (state.board[i] == 2) {
        blackLegalMoveIndexes(i).forEach((location) {
          if (location < C.TOTAL_TILES) {
            var m = new Move(state.turn, i, location, 0);
            if (isLegalMove(m)) {
              legalMoves.add(m);
            }
          }
        });
      }
    }
    return legalMoves;
  }

  bool isIllegalCapture(Move move) {
    int diff = move.to - move.from;
    return diff.abs() == C.BOARD_SIZE && state.board[move.to] != C.EMPTY_NUM;
  }

  List<int> whiteLegalMoveIndexes(int location) {
    return [
      location - C.BOARD_SIZE,
      location - C.BOARD_SIZE - 1,
      location - C.BOARD_SIZE + 1,
    ];
  }

  List<int> blackLegalMoveIndexes(int location) {
    return [
      location + C.BOARD_SIZE,
      location + C.BOARD_SIZE - 1,
      location + C.BOARD_SIZE + 1,
    ];
  }

  bool isLegalMove(Move move) {
    if (isIllegalCapture(move) ||
        state.board[move.from] != Piece.colorToInt(state.turn) ||
        state.board[move.from] == state.board[move.to]) return false;

    if (move.color == C.WHITE) {
      return whiteLegalMoveIndexes(move.from).contains(move.to);
    } else {
      return blackLegalMoveIndexes(move.from).contains(move.to);
    }
  }

  void make_move(Move move) {
    state.board.apply(move);
  }

  void reverseTurn() {
    state.turn = state.turn == WHITE ? BLACK : WHITE;
  }

  void makeAIMove() {
    Move move = ai.selectMove(getLegalMoves(state.turn));
    print('CHOSEN AI MOVE: ${move.from} ${move.to}');
    this.move(move);
  }
}


class Piece {
  final Color color;
  PieceType type;
  Piece(this.color) {
    this.type = Piece.colorToPieceType(this.color);
  }

  static PieceType colorToPieceType(Color color) {
    if (color == C.WHITE) return PieceType.WHITE;
    return PieceType.BLACK;
  }

  static int colorToInt(Color color) {
    if (color == C.WHITE) return 1;
    return 2;
  }

  static Color intToColor(int num) {
    if (num == 1) return C.WHITE;
    return C.BLACK;
  }
}

enum PieceType {
  WHITE,
  BLACK,
  EMPTY
}

class Move {
  final Color color;
  final int from;
  final int to;
  final int flags;
  const Move(this.color, this.from, this.to, this.flags);
}

class Board {
  List<int> board = new List(C.BOARD_SIZE * C.BOARD_SIZE);

  operator [](index) => board[index];

  List<int> slice(int start, int end) {
    return board.sublist(start, end);
  }
  
  List<int> bottomRow() {
    return board.sublist(C.TOTAL_TILES - C.BOARD_SIZE, C.TOTAL_TILES);
  }

  List<int> topRow() {
    return board.sublist(0, C.BOARD_SIZE);
  }

  bool apply(Move move) {
    // occupied by own piece
    if (board[move.to] == board[move.from]) return false;

    board[move.from] = C.EMPTY_NUM;
    board[move.to] = Piece.colorToInt(move.color);
    printBoard();
    return true;
  }

  void initBoard() {
    for (int i = 0; i < C.BOARD_SIZE * C.BOARD_SIZE; ++i) {
      board[i] = C.EMPTY_NUM;
    }

    for (int i = 0; i < C.BOARD_SIZE * 2; ++i) {
      board[i] = C.BLACK_NUM;
    }

    for (int i = (C.BOARD_SIZE * C.BOARD_SIZE) - C.BOARD_SIZE * 2; i < C.BOARD_SIZE * C.BOARD_SIZE; ++i) {
      board[i] = C.WHITE_NUM;
    }

  }

  Board copy() {
    return new Board()
      ..board = new List<int>.from(this.board);
  }

  void printBoard() {
    print("");
    for (int i = 0; i < 63 - 6; i += C.BOARD_SIZE) {
      print(board.sublist(i, i+C.BOARD_SIZE - 1));
    }
    print("");
  }

}

class State {
    Board board;
    Color turn;
    State(this.board, this.turn);
}
