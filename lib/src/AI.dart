import 'package:flutter/material.dart' as flut;
import 'constants.dart' as C;
import 'game_engine.dart';
import 'dart:math';

/// Base AI class containing common methods for heuristic evaluation
abstract class AI {
  flut.Color maximisingPlayer;
  static const double ALPHA_INIT = -100000;
  static const double BETA_INIT = 100000;
  static const double ALMOST_WIN_VAL = 10;
  static const double PIECE_VALUE = 1;
  static const double CAPTURE_DANGER_VAL = -10;
  static const double HOME_GROUND_VAL = 2;

  Move selectMove(List<Move> legalMoves, State state);

  double staticallyEvaluate(State state) {
    if (state.isGameOver() && state.turn != this.maximisingPlayer)  {
      return BETA_INIT;
    }

    if (state.isGameOver() && state.turn == this.maximisingPlayer) {
      return ALPHA_INIT;
    }


    int maxPiece = state.turn != this.maximisingPlayer ? 1 : 2;
    int minPiece = maxPiece == 1 ? 2: 1;
    double total = 0;
    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      if (state.board[i] == maxPiece) {
        ++total;
        total += i / C.BOARD_SIZE;
      } else if (state.board[i] == minPiece) {
        --total;
        total -= C.BOARD_SIZE - i / C.BOARD_SIZE;
      }
    }

    return total;
  }

  double evalHeuristic(State state, int maxPiece, int minPiece) {
    double boardValue = 0;
    Board board = state.board;
    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      if (board[i] == maxPiece) {
        // value of having the piece on the board
        boardValue += getValOfSquare(i, board);
      } else if (board[i] == minPiece) {
        // for opponent stuff
        boardValue -= getValOfSquare(i, board);
      }
    }
  }

  double getValOfSquare(int i, Board board) {
    double total = 0;
    total += PIECE_VALUE;

    // bonus of piece being close to winning
    Point p = board.IntToCoord(i);
    total += closeToWin(p.y, this.maximisingPlayer);

    // capture danger bonus
    total += captureDanger(p, this.maximisingPlayer, board);

    // bonus for being vertically and horizontally connected with other pieces you own
    total += connected(p, board);

    // bonus for being home ground
    total += homeGround(p, this.maximisingPlayer);
  }

  double homeGround(Point p, flut.Color player) {
    if (player == C.WHITE && p.y == C.BOARD_SIZE - 1) return HOME_GROUND_VAL;
    if (player == C.BLACK && p.y == 0) return HOME_GROUND_VAL;
    return 0;
  }

  double connected(Point p, Board board) {
    double total = 0;
    int player = board.get(p.x, p.y);
    if (p.y > 0 && board.get(p.x, p.y-1) == player) ++total;
    if (p.y < C.BOARD_SIZE - 1 && board.get(p.x, p.y+1) == player) ++total;

    if (p.x > 0 && board.get(p.x-1, p.y) == player) ++total;
    if (p.x < C.BOARD_SIZE - 1 && board.get(p.x+1, p.y) == player) ++total;
    return total;
  }

  double closeToWin(y, flut.Color toPlay) {
    if (toPlay == C.WHITE && y < C.BOARD_SIZE / 2) {
      return ALMOST_WIN_VAL;
    } else if (toPlay == C.BLACK_NUM && y > C.BOARD_SIZE / 2) {
      return ALMOST_WIN_VAL;
    }
    return 0;
  }

  double captureDanger(Point point, flut.Color toPlay, Board board) {
    int modifier = toPlay == C.WHITE ? -1 : 1;
    int player = board.get(point.x, point.y);
    int opponent = player == 1 ? 2 : 1;

    if (board.get(point.x-1, point.y + modifier) == opponent || board.get(point.x+1, point.y + modifier) == opponent)
      return CAPTURE_DANGER_VAL;
    return 0;
  }
}

/// Shitty little random player
class RandomAI extends AI {
  Random rng = new Random();

  Move selectMove(List<Move> legalMoves, State state) {
    return legalMoves[rng.nextInt(legalMoves.length)];
  }
}

/// Negamx player using iterative deepening
class NegamaxAI extends AI {
  int maxDepth = 5;

  bool searchedFullTree = false;

  Move selectMove(List<Move> legalMoves, State state) {
    maximisingPlayer = state.turn;
    return iterativeDeepening(legalMoves, state);
  }

  Move iterativeDeepening(List<Move> legalMoves, State state) {
    int searchDepth = 0;
    legalMoves.shuffle();
    int numRootMoves = legalMoves.length;

    Map<int, double> moveScores = {};
    Move bestMove = legalMoves[0];
    while (searchDepth < this.maxDepth) {
      ++searchDepth;

      double score = AI.ALPHA_INIT;
      double alpha = AI.ALPHA_INIT;
      double beta = AI.BETA_INIT;
      double value = 1;

      for (int i = 0; i < numRootMoves; ++i) {
        State copyState = state.copy();
        Move m = legalMoves[i];
        copyState.applyMove(m);
        value = -negamax(copyState, searchDepth-1, -beta, -alpha);
        // moveScores[i] = value;

        if (value > score) {
          score = value;
          bestMove = m;
        }

        if (score > alpha)
          alpha = score;

        if (alpha >= beta)
          break;
      }

      if (bestMove != null) {
        if (score == AI.BETA_INIT) {
          print('Win proven at depth $searchDepth');
          return bestMove;
        } else if (score == AI.ALPHA_INIT) {
          print('Loss proven at depth $searchDepth');
          return bestMove;
        }
      }

      // legalMoves.sort((m1, m2) => moveScores[legalMoves.indexOf(m1)].compareTo(moveScores[legalMoves.indexOf(m2)]));
      // moveScores = {};
    }
    print('Completed search of depth $searchDepth');
    return bestMove;
  }

  double negamax(State state, int depth, double alpha, double beta) {
    if (state.isGameOver() || depth == 0) {
      double eval = staticallyEvaluate(state);
      return eval;
    }

    List<Move> legalMoves = state.getLegalMoves(state.turn);
    final int numLegalMoves = legalMoves.length;
    double value = AI.ALPHA_INIT;
    for (int i = 0; i < numLegalMoves; ++i) {
      State copyState = state.copy();
      Move m = legalMoves[i];
      copyState.applyMove(m);
      value = -negamax(copyState, depth - 1, -beta, -alpha);

      if (value > alpha) {
        alpha = value;
      }


      if (alpha >= beta)
        break;
    }
    return value;
  }
}