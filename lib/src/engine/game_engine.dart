import 'dart:math';
import 'constants.dart' as C;
import 'ai_players.dart';

class GameEngine {
  static const int BLACK = C.BLACK;
  static const int WHITE = C.WHITE;

  // unused ATM
  static const Map<String, String> FLAGS = const {
    'NORMAL': 'n',
    'CAPTURE' : 'c'
  };
  static const int BITS_NORMAL = 1;
  static const int BITS_CAPTURE = 2;

  // Convert board squares from the frontend to our backend representation
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

  // Instance member stuff
  State state =  new State(new Board(), WHITE);
  List<State> history = [];
  bool gameOver = false;
  AI ai;
  AI ai2;
  int AIDifficulty;
  int AI2Difficulty;


  GameEngine(int difficulty, int a2difficulty, bool bothai) {
    state.board.initBoard();
    this.AIDifficulty = difficulty;
    this.AI2Difficulty = a2difficulty;
    switch(this.AIDifficulty) {
      case 1:
        ai = RandomAI();
        break;
      case 2:
        ai = FlatMCTSAI();
        break;
      case 3:
        ai = NegamaxAI(C.WANDERER_HEURISTIC);
        break;
    }
    if (bothai) {
      switch (this.AI2Difficulty) {
        case 1:
          ai2 = RandomAI();
          break;
        case 2:
          ai2 = FlatMCTSAI();
          break;
        case 3:
          ai2 = NegamaxAI(C.WANDERER_HEURISTIC);
          break;
      }
    }
  }

  /// reset the game
  void reset() {
    State state =  new State(new Board(), WHITE);
    List<State> history = [];
    bool gameOver = false;
  }

  /// get the piece value of a square
  Piece get(String square) {
    int boardInt = state.board.board[SQUARES[square]];
    // no piece ont his square
    if (boardInt == 0) return null;
    return Piece(Piece.intToColor(boardInt));
  }

  /// Try to apply a move
  /// returns true of the move was successful
  bool move(move) {
    Move m = null;
    if (move is Map) {
      // frontend breaks without this part
      int from = SQUARES[move['from']];
      int to = SQUARES[move['to']];
      print('to $to : from $from');
      m = new Move(state.turn, from, to, 0);
    } else if (move is Move) {
      m = move;
    }

    // obvs don't play an illegal move
    if (m == null || !state.isLegalMove(m)) return false;

    state.applyMove(m);
    if (state.isGameOver()) {
      this.gameOver = true;
    }
    return true;
  }

  /// Make move for the AI player
  void makeAIMove() {
    Move move = ai.selectMove(state.getLegalMoves(state.turn), state);
    print('CHOSEN AI MOVE: ${move.from} ${move.to}');
    this.move(move);
  }

  void makeAI2Move() {
    Move move = ai2.selectMove(state.getLegalMoves(state.turn), state);
    print('CHOSEN AI MOVE: ${move.from} ${move.to}');
    this.move(move);
  }

  /// Play a game with two AI players, used only for testing
  String AIPlayout(AI a1, AI a2) {
    State s = new State(new Board(), C.WHITE);
    s.board.initBoard();
    Move m;
    while(true) {

      // make a move for white
      m = a1.selectMove(s.getLegalMoves(C.WHITE), s);
      if (m != null) {
        print('${a1.getName()}: $m');
        s.applyMove(m);
        // s.board.printBoard();
        if (s.isGameOver()) {
          return a1.getName();
        }
      } else {
        // automatic loss if white has no moves to play
        print('a1 has no moves rip');
        return a2.getName();
      }

      // make a move for black
      m = a2.selectMove(s.getLegalMoves(C.BLACK), s);
      if (m != null) {
        print('${a2.getName()}: $m');
        s.applyMove(m);
        // s.board.printBoard();
        if (s.isGameOver()) {
          return a2.getName();
        }
      } else {
        // automatic loss for black is no moves to play
        print('a2 has no moves rip');
        return a1.getName();
      }
    }
  }
}


/// This is really only used to pass information to the frontend
class Piece {
  final int color;
  PieceType type;
  Piece(this.color) {
    this.type = Piece.colorToPieceType(this.color);
  }

  static PieceType colorToPieceType(int color) {
    if (color == C.WHITE) return PieceType.WHITE;
    return PieceType.BLACK;
  }

  static int colorToInt(int color) {
    if (color == C.WHITE) return 1;
    return 2;
  }

  static int intToColor(int num) {
    if (num == 1) return C.WHITE;
    return C.BLACK;
  }
}

enum PieceType {
  WHITE,
  BLACK,
  EMPTY
}

/// All the information need about a particular move
class Move {
  final int color;
  final int from;  // the square we want to move away from
  final int to;    // the square we want to move to
  final int flags; // currently unused
  const Move(this.color, this.from, this.to, this.flags);
  toString() {
    return '$color plays $from to $to';
  }
}

/// Game board representation
class Board {
  // 1D representation of the game board
  List<int> board = new List(C.BOARD_SIZE * C.BOARD_SIZE);

  operator [](index) => board[index];

  List<int> slice(int start, int end) {
    return board.sublist(start, end);
  }

  /// get the value of a square using x and y coordinates
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

    board[move.from] = C.EMPTY;
    board[move.to] = Piece.colorToInt(move.color);
    // printBoard();
    return true;
  }

  void initBoard() {
    for (int i = 0; i < C.BOARD_SIZE * C.BOARD_SIZE; ++i) {
      board[i] = C.EMPTY;
    }

    for (int i = 0; i < C.BOARD_SIZE * 2; ++i) {
      board[i] = C.BLACK;
    }

    for (int i = (C.BOARD_SIZE * C.BOARD_SIZE) - C.BOARD_SIZE * 2; i < C.BOARD_SIZE * C.BOARD_SIZE; ++i) {
      board[i] = C.WHITE;
    }

  }

  Point IntToCoord(int location) {
    int y = (location / C.BOARD_SIZE).floor();
    int x = location % C.BOARD_SIZE;
    return new Point(x, y);
  }

  int coordToInt(int x, int y) {
      if (x >= 0 && y >= 0 && x < C.BOARD_SIZE && y < C.BOARD_SIZE)
        return (C.BOARD_SIZE) * x + y;
      return -1;
  }

  static bool isValidPoint(int x, int y) {
    return (x >= 0 && x < C.BOARD_SIZE) && (y >= 0 && y < C.BOARD_SIZE);
  }

  /// deep copy of the board (I think)
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

  bool legalLocation(int location) {
    return location < C.TOTAL_TILES && location >= 0;
  }

}

/// Representation of the state of a particular instance of the game
class State {
    Board board;  // state of the board
    int turn;     // who's to play
    State(this.board, this.turn);

    void reverseTurn() {
      turn = turn == C.WHITE ? C.BLACK : C.WHITE;
    }

    static int opponent(int color) {
      return color == C.WHITE ? C.BLACK : C.WHITE;
    }

    /// White has made it to the top row, or black has made it to the bottom row
    bool isGameOver() {
      return board.topRow().contains(1) || board.bottomRow().contains(2);
    }

    /// returns the winning color
    /// return 0 if there is no winner
    int winner() {
      if (board.topRow().contains(C.WHITE)) return C.WHITE;
      if (board.bottomRow().contains(C.BLACK)) return C.BLACK;
      return 0;
    }

    void applyMove(Move move) {
      board.apply(move);
      reverseTurn();
    }

    State copy() {
      return new State(board.copy(), turn);
    }

    /// Returns all the legal moves for a given color
    List<Move> getLegalMoves(int toPlay) {
      List<Move> legalMoves = [];
      for (int i = 0; i < C.TOTAL_TILES; ++i) {
        if (board[i] == toPlay) {
          legalMoves.addAll(legalMovesForPosition(i, toPlay));
        }
      }
      return legalMoves;
    }

    /// Returns the board position indexes of the the possibly legal
    /// moves for a given position and color
    List<int> getLegalMoveIndexes(int location, int toPlay) {
      int verticalModifier;
      // White can only move up, and black can only move down
      if (toPlay == C.WHITE) {
        verticalModifier = -C.BOARD_SIZE;
      } else {
        verticalModifier = C.BOARD_SIZE;
      }

      if (board.IntToCoord(location).x == 0) {
        return [
          location + verticalModifier,
          location + verticalModifier + 1,
        ];
      } else if (board.IntToCoord(location).x == C.BOARD_SIZE - 1) {
        return [
          location + verticalModifier,
          location + verticalModifier - 1,
        ];
      }
      return [
        location + verticalModifier,
        location + verticalModifier - 1,
        location + verticalModifier + 1,
      ];
    }

    /// returns true if the move would capture an enemy piece directly in front
    /// of it
    bool isIllegalCapture(Move move) {
      int diff = move.to - move.from;
      return diff.abs() == C.BOARD_SIZE && board[move.to] != C.EMPTY;
    }

    /// returns true of the move is a legal move
    bool isLegalMove(Move move) {
      if (isIllegalCapture(move) ||
          // trying to move a piece you don't own
          board[move.from] != Piece.colorToInt(turn) ||
          // trying to move to a square you already have a piece in
          board[move.from] == board[move.to]) return false;
      // check that move.to is a legal board position for move.from to move to
      return getLegalMoveIndexes(move.from, move.color).contains(move.to);
    }

    /// returns all the legal moves for a given position and color
    List<Move> legalMovesForPosition(int position, int toPlay) {
      List<Move> moves = [];
      getLegalMoveIndexes(position, toPlay).forEach((location) {
        if (board.legalLocation(location)) {
          Move m = new Move(toPlay, position, location, 0);
          if (isLegalMove(m)) {
            moves.add(m);
          }
        }
      });
      return moves;
    }
}

class Point {
  int x;
  int y;
  Point(this.x, this.y);

  double distance(Point other) {
    return sqrt(pow((this.x - other.x), 2).toDouble() + pow(this.y - other.y, 2).toDouble());
  }

  @override
  String toString() {
    return 'x: $x ; y: $y';
  }
}

