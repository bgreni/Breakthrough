import 'constants.dart' as C;
import 'AI.dart';
import 'game_engine.dart';

class Heuristic {
  static const double ALPHA_INIT = double.negativeInfinity;
  static const double BETA_INIT = double.infinity;
  static const double ALMOST_WIN_VAL = 10000;
  static const double PIECE_VALUE = 1300;
  static const double CAPTURE_DANGER_VAL = -100;
  static const double HOME_GROUND_VAL = 10;
  static const double CONNECTED_HVAL = 35;
  static const double CONNECTED_VVAL = 15;

  double evalHeuristic(State state, int maxPiece, int minPiece, int maximisingPlayer) {
    double boardValue = 0;
    Board board = state.board;
    int maxPieces = 0;
    int minPieces = 0;

    if (state.isGameOver()) {
      if (state.turn != maximisingPlayer) {
        return BETA_INIT;
      } else {
        return ALPHA_INIT;
      }

    }

    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      if (board[i] == maxPiece) {
        ++maxPieces;
        // value of having the piece on the board
        boardValue += getValOfSquare(i, state, maximisingPlayer);
      } else if (board[i] == minPiece) {
        ++minPieces;
        // for opponent stuff
        boardValue -= getValOfSquare(i, state, maximisingPlayer);
      }
    }
    if (maxPieces == 0) {
      return ALPHA_INIT;
    } else if (minPieces == 0) {
      return BETA_INIT;
    }

    return boardValue;
  }

  double getPieceValue(int i, State state) {
    double value = PIECE_VALUE;
    Point p = state.board.IntToCoord(i);
    value += connected(p, state.board);
    value += state.legalMovesForPosition(i, state.turn).length;

    return value;
  }

  double getValOfSquare(int i, State state, int maximisingPlayer) {
    double total = 0;
    Board board = state.board;
    total += getPieceValue(i, state);

    // bonus of piece being close to winning
    Point p = board.IntToCoord(i);
    // total += closeToWin(p, maximisingPlayer, board);

    // capture danger bonus
    total += captureDanger(p, maximisingPlayer, board);

    // bonus for being home ground
    total += homeGround(p, maximisingPlayer);

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
    int player = board.get(point.x, point.y);
    int opponent = player == 1 ? 2 : 1;
    int modifiedy = point.y + modifier;
    if ((point.x > 0 && yInRange(modifiedy) && board.get(point.x-1, modifiedy) == opponent) ||
        (point.x < C.BOARD_SIZE - 1 && yInRange(modifiedy) && board.get(point.x+1, modifiedy) == opponent))
      return CAPTURE_DANGER_VAL;
    return 0;
  }

  bool yInRange(int y) {
    return y > 0 && y < C.BOARD_SIZE;
  }
}