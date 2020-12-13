import '../constants.dart' as C;
import '../game_engine.dart';
import 'dart:math';
import '../transposition_table.dart';
import 'dart:async';
import 'breakthrough_heuristic.dart';

/// Base AI class containing common methods for heuristic evaluation
abstract class AI {
  int maximisingPlayer;
  static const double ALPHA_INIT = double.negativeInfinity;
  static const double BETA_INIT = double.infinity;


  TranspositionTable tt = new TranspositionTable();
  ZobristHash hasher = new ZobristHash();
  Heuristic heuristic = new Heuristic();


  Move selectMove(List<Move> legalMoves, State state);
  String getName();

  double staticallyEvaluate(State state) {
    int winner = state.winner();
    if (winner != this.maximisingPlayer && winner != 0) {
      return BETA_INIT;
    }

    if (state.winner() == this.maximisingPlayer) {
      return ALPHA_INIT;
    }

    int maxPiece = state.turn != this.maximisingPlayer ? 1 : 2;
    int minPiece = maxPiece == 1 ? 2 : 1;

    return heuristic.evalHeuristic(state, maxPiece, minPiece, this.maximisingPlayer);
  }
}




/// Shitty little random player
class RandomAI extends AI {
  Random rng = new Random();

  String getName() {
    return "Random";
  }

  Move selectMove(List<Move> legalMoves, State state) {
    if (legalMoves.length == 0) return null;
    return legalMoves[rng.nextInt(legalMoves.length)];
  }
}






