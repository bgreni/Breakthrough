
import 'dart:math';

import '../constants.dart' as C;
import 'AI.dart';
import '../game_engine.dart';

class Heuristic {
  static const double ALPHA_INIT = double.negativeInfinity;
  static const double BETA_INIT = double.infinity;
  static const double ALMOST_WIN_VAL = 10000;
  static const double PIECE_VALUE = 1300;
  static const double CAPTURE_DANGER_VAL = -100;
  static const double HOME_GROUND_VAL = 10;
  static const double CONNECTED_HVAL = 35;
  static const double CONNECTED_VVAL = 15;

  static const List<double> BOARD_SQUARE_VALS = [
    5, 28, 28, 12, 12, 28, 28, 5,
    2, 3, 3, 3, 3, 3, 3, 2,
    3, 5 , 10, 10, 10, 10, 5, 3,
    6, 9, 16, 16, 16, 16, 9, 6,
    9, 15, 21, 21, 21, 21, 15, 9,
    14, 22, 22, 22, 22, 22, 22, 14,
    21, 23, 23, 23, 23, 23, 23, 21,
    24, 24, 24, 24, 24, 24, 24, 24
  ];

  final String type;

  Heuristic(this.type);


  // static const SIDE_PROX_VALS = [1.3199687, 1.6717433];
  // static const CENTER_PROX_VALS = [-0.60074246, 2.1167464];
  // static const double PIECE_WEIGHT = 1.0;
  // static const double MOBILITY = 0.19138491;
  // static const END_REGION_WHITE = [-0.029624522, 1.5196275];
  // static const END_REGION_BLACK = [1.3905222, 0.9268772];
  // final CENTER_P = new Point(4, 4);
  //
  // static const double MAX_DIST = 1;

  static const double PIECE = 10;



  double evalHeuristic(State state, int maxPiece, int minPiece, int maximisingPlayer) {
    double boardValue = 0;
    Board board = state.board;
    int maxPieces = 0;
    int minPieces = 0;

    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      if (board[i] == maxPiece) {
        ++maxPieces;
        // value of having the piece on the board
        if (this.type == C.ARTICLE_HEURISTIC) {
          boardValue += getValOfSquare(i, state, maxPiece);
        } else {
          boardValue += computeTerms(i, maxPiece, state);
        }
      } else if (board[i] == minPiece) {
        ++minPieces;

        // for opponent stuff
        if (this.type == C.ARTICLE_HEURISTIC) {
          boardValue -= getValOfSquare(i, state, maxPiece);
        } else {
          boardValue -= computeTerms(i, maxPiece, state);
        }
      }
    }
    if (maxPieces == 0) {
      return ALPHA_INIT;
    } else if (minPieces == 0) {
      return BETA_INIT;
    }

    return boardValue;
  }

  double computeTerms(int location, int player, State state) {
    double total = 0;
    Point p = state.board.IntToCoord(location);
    total += PIECE;
    double squareValue = getSquareValue(location, player);
    total += squareValue;
    total += breakthroughBonus(p, player, state.board, State.opponent(player));
    if (!isInDanger(p, player, state.board))
      total += squareValue * 0.5;
    total += connected(p, state.board) / 10;


    // total += computeSidesProximity(p.x, player);
    // total += computerCenterProximity(p, player);
    // total += computeMobility(location, player, state);
    // total += PIECE_WEIGHT;
    // total += computeEndRegion(p.y, player);
    return total;
  }

  bool isInDanger(Point p, int player, Board board) {
    int yModifier = player == C.WHITE ? -1 : 1;
    int opponent = State.opponent(player);
    if (Board.isValidPoint(p.x - 1, p.y + yModifier) && board.get(p.x - 1, p.y + yModifier) == opponent)
      return true;
    if (Board.isValidPoint(p.x + 1, p.y + yModifier) && board.get(p.x + 1, p.y + yModifier) == opponent)
      return true;
    return false;
  }

  double breakthroughBonus(Point p, int player, Board board, int opponent) {
    double count = 0;
    int yModifier = player == C.WHITE ? -1 : 1;
    for (int i = p.y + yModifier; i > p.y + (yModifier * 3); --i) {
      for (int j = p.x - 1; j < p.x + 2; ++j) {
        if (Board.isValidPoint(j, i) && board.get(j, i) != opponent)
          ++count;
      }
    }
    return count;
  }


  double getSquareValue(int location, int player) {
    if (player == C.BLACK)
      return BOARD_SQUARE_VALS[location];
    return BOARD_SQUARE_VALS.reversed.toList()[location];

  }

















  // double computeSidesProximity(int x, int player) {
  //   double distance = min(x, C.BOARD_SIZE - x).toDouble();
  //   return SIDE_PROX_VALS[player - 1] * (1.0 - distance / MAX_DIST);
  // }
  //
  // double computerCenterProximity(Point p, int player) {
  //   double distance = p.distance(CENTER_P);
  //   return CENTER_PROX_VALS[player - 1] * (1.0 - distance / MAX_DIST);
  // }
  //
  // double computeMobility(int location, int player, State state) {
  //   return MOBILITY * state.legalMovesForPosition(location, player).length;
  // }
  //
  // double computeEndRegion(int y, int player) {
  //   double total = 0;
  //   total += END_REGION_WHITE[player - 1] * (1.0 - (C.BOARD_SIZE - y / MAX_DIST));
  //   return total + END_REGION_BLACK[player - 1] * (1.0 - (y / MAX_DIST));
  // }




























  double getPieceValue(int i, State state, int player) {
    double value = PIECE_VALUE;
    // Point p = state.board.IntToCoord(i);
    // value += connected(p, state.board);
    value += state.legalMovesForPosition(i, player).length;

    return value;
  }

  double getValOfSquare(int i, State state, int player) {
    double total = 0;
    Board board = state.board;
    total += getPieceValue(i, state, player);

    // bonus of piece being close to winning
    Point p = board.IntToCoord(i);
    total += closeToWin(p, player, board);

    // capture danger bonus
    total += captureDanger(p, player, board);

    // bonus for being home ground
    total += homeGround(p, player);

    return total;
  }

  double homeGround(Point p, int player) {
    if (player == C.WHITE && p.y == C.BOARD_SIZE - 1) return HOME_GROUND_VAL;
    if (player == C.BLACK && p.y == 0) return HOME_GROUND_VAL;
    return 0;
  }

  double connected(Point p, Board board) {
    double total = 0;
    int player = board.get(p.x, p.y);
    if (p.y > 0 && board.get(p.x, p.y-1) == player) total += CONNECTED_VVAL;
    if (p.y < C.BOARD_SIZE - 1 && board.get(p.x, p.y+1) == player) total += CONNECTED_VVAL;

    if (p.x > 0 && board.get(p.x-1, p.y) == player) total += CONNECTED_HVAL;
    if (p.x < C.BOARD_SIZE - 1 && board.get(p.x+1, p.y) == player) total += CONNECTED_HVAL;
    return total;
  }

  double closeToWin(Point p, int toPlay, Board board) {
    if (toPlay == C.WHITE && p.y == 1 && captureDanger(p, toPlay, board) == 0) {
      return ALMOST_WIN_VAL;
    } else if (toPlay == C.BLACK && p.y == C.BOARD_SIZE - 2 && captureDanger(p, toPlay, board) == 0) {
      return ALMOST_WIN_VAL;
    }
    return 0;
  }

  double captureDanger(Point point, int toPlay, Board board) {
    int modifier = toPlay == C.WHITE ? -1 : 1;
    int player = toPlay;
    int opponent = State.opponent(player);
    int modifiedy = point.y + modifier;
    if ((point.x > 0 && yInRange(modifiedy) && board.get(point.x-1, modifiedy) == opponent) ||
        (point.x < C.BOARD_SIZE - 1 && yInRange(modifiedy) && board.get(point.x+1, modifiedy) == opponent))
      return CAPTURE_DANGER_VAL;
    return 0;
  }

  bool yInRange(int y) {
    return y >= 0 && y <= C.BOARD_SIZE - 1;
  }
}