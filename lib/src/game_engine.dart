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
  AI ai = NegamaxAI();


  GameEngine() {
    state.board.initBoard();
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

    if (m == null || !state.isLegalMove(m)) return false;
    make_move(m);
    if (state.isGameOver()) {
      this.gameOver = true;
    }
    return true;
  }



  void make_move(Move move) {
    state.applyMove(move);
  }

  void makeAIMove() {
    Move move = ai.selectMove(state.getLegalMoves(state.turn), state);
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

  int get(int x, int y) {
    return board[coordToInt(x, y)];
  }
  
  List<int> bottomRow() {
    return board.sublist(C.TOTAL_TILES - C.BOARD_SIZE, C.TOTAL_TILES);
  }

  List<int> topRow() {
    return board.sublist(0, C.BOARD_SIZE);
  }

  List<int> leftColumn() {
    return [0, 8, 16, 24, 42, 40, 48, 56];
  }

  List<int> rightColumn() {
    return [7, 15, 23, 31, 39, 47, 55, 63];
  }

  bool apply(Move move) {
    // occupied by own piece
    if (board[move.to] == board[move.from]) return false;

    board[move.from] = C.EMPTY_NUM;
    board[move.to] = Piece.colorToInt(move.color);
    // printBoard();
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

  Point IntToCoord(int location) {
    int y = (location / C.BOARD_SIZE).floor();
    int x = location % C.BOARD_SIZE;
    return new Point(x, y);
  }

  int coordToInt(int x, int y) {
      return (C.BOARD_SIZE + 1) * x + y;
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

    void reverseTurn() {
      turn = turn == C.WHITE ? C.BLACK : C.WHITE;
    }

    bool isGameOver() {
      return board.topRow().contains(1) || board.bottomRow().contains(2);
    }

    void applyMove(Move move) {
      board.apply(move);
      reverseTurn();
    }

    State copy() {
      return new State(board.copy(), new Color(turn.value));
    }

    List<Move> getLegalMoves(Color toPlay) {
      List<Move> legalMoves = [];
      for (int i = 0; i < C.TOTAL_TILES; ++i) {
        int player = Piece.colorToInt(toPlay);
        if (board[i] == player) {
          var locations = getLegalMoveIndexes(i, toPlay);
          locations.forEach((location) {
            if (location < C.TOTAL_TILES) {
              var m = new Move(turn, i, location, 0);
              if (isLegalMove(m)) {
                legalMoves.add(m);
              }
            }
          });
        }
      }
      return legalMoves;
    }

    List<int> getLegalMoveIndexes(int location, Color toPlay) {
      int bs;
      if (toPlay == C.WHITE) {
        bs = -C.BOARD_SIZE;
      } else {
        bs = C.BOARD_SIZE;
      }

      if (board.leftColumn().contains(location)) {
        return [
          location + bs,
          location + bs + 1,
        ];
      } else if (board.rightColumn().contains(location)) {
        return [
          location + bs,
          location + bs - 1,
        ];
      }
      return [
        location + bs,
        location + bs - 1,
        location + bs + 1,
      ];
    }

    bool isIllegalCapture(Move move) {
      int diff = move.to - move.from;
      return diff.abs() == C.BOARD_SIZE && board[move.to] != C.EMPTY_NUM;
    }

    bool isLegalMove(Move move) {
      if (isIllegalCapture(move) ||
          board[move.from] != Piece.colorToInt(turn) ||
          board[move.from] == board[move.to]) return false;

      return getLegalMoveIndexes(move.from, move.color).contains(move.to);
    }
}

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}
