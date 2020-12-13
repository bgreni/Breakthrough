import 'constants.dart' as C;
import 'game_engine.dart';
import 'dart:math';
import 'transposition_table.dart';
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

/// Negamax player using iterative deepening
class NegamaxAI extends AI {
  int maxDepth = 5;
  bool searchedFullTree = false;
  int maxSeconds = 5;
  Stopwatch watch = new Stopwatch();


  String getName() {
    return "Negamax";
  }

  Move selectMove(List<Move> legalMoves, State state) {
    this.maximisingPlayer = state.turn;
    watch.reset();
    watch.start();
    return iterativeDeepening(legalMoves, state);
  }

  Move iterativeDeepening(List<Move> legalMoves, State state) {

    int searchDepth = 0;
    legalMoves.shuffle();
    int numRootMoves = legalMoves.length;

    if (legalMoves.length == 0) {
      print('no moves fam');
      return null;
    }

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

        if (shouldStop()) break;

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
    
    // int hash = hasher.doHash(state.board.board);
    //
    // if (tt.contains(hash) && tt[hash].depth >= depth) {
    //   return tt[hash].value;
    // }
    
    if (state.isGameOver() || depth == 0) {
      double eval = staticallyEvaluate(state);
      return eval;
      // return tt.put(hash, eval, depth);
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

      if (shouldStop()) break;


      if (alpha >= beta)
        break;
    }

    // return tt.put(hash, value, depth);
    return value;
  }

  bool shouldStop() {
    return watch.elapsed.inSeconds >= maxSeconds;
  }

}

class FlatMCTSAI extends AI {
  Stopwatch watch = new Stopwatch();
  static const int PLAYOUT_TIME = 1;

  String getName() {
    return "FlatMCTS";
  }

  Move selectMove(List<Move> legalMoves, State state) {
    List<int> wins = new List.filled(legalMoves.length, 0);
    int counter = 0;
    watch.reset();
    watch.start();
    while(watch.elapsed.inSeconds < PLAYOUT_TIME) {
      for (int j = 0; j < legalMoves.length; ++j) {
        ++counter;
        PlayoutResult result = playout(legalMoves[j], state.copy());
        if (result.didWin) {
          wins[j] += 1;
        }
      }
    }
    watch.stop();
    print('Sims completed $counter');
    return legalMoves[wins.indexOf(wins.reduce(max))];
  }

  PlayoutResult playout(Move move, State state) {
    int turns = 1;
    int wantWin = state.turn;
    state.applyMove(move);

    while (!state.isGameOver()) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[Random.secure().nextInt(moves.length)]);
    }
    bool didWin = false;
    if (state.turn != wantWin || state.isGameOver()) {
      didWin = true;
    }
    return new PlayoutResult(turns, didWin);
  }

}

class PlayoutResult {
  int numTurns;
  bool didWin;
  PlayoutResult(this.numTurns, this.didWin);
}


class UCTAI extends AI {

  Stopwatch watch = new Stopwatch();
  final int PLAYOUT_TIME = 1;
  final double EXPLOIT = sqrt2;


  String getName() {
    return "UCT";
  }

  Move selectMove(List<Move> legalMoves, State state) {
    List<StatsEntry> stats = new List.generate(legalMoves.length, (index) => StatsEntry(), growable: false);
    int counter = 0;
    watch.reset();
    watch.start();
    while(watch.elapsed.inSeconds < PLAYOUT_TIME) {
      int index = findBest(stats, counter);
      if (playout(legalMoves[index], state.copy()))
        stats[index].wins += 1;
      stats[index].attempts += 1;
      ++counter;
    }
    watch.stop();
    print('Sims completed $counter');
    stats.sort((a, b) => a.wins.compareTo(b.wins));
    return legalMoves[stats.indexOf(stats.reversed.toList()[0])];
  }

  int findBest(List<StatsEntry> stats, int n) {
    int best = -1;
    double bestScore = double.negativeInfinity;
    for (int i = 0; i < stats.length; ++i) {
      double score = ucb(stats, i, n);
      if (score > bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  double ucb(List<StatsEntry> stats, int i, int n) {
    if (stats[i].attempts == 0) return double.infinity;
    return stats[i].winRate() + EXPLOIT * sqrt(log(n) / stats[i].attempts);
  }


  bool playout(Move move, State state) {
    int wantWin = state.turn;
    state.applyMove(move);

    while (!state.isGameOver()) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[Random.secure().nextInt(moves.length)]);
    }
    bool didWin = false;
    if (state.turn != wantWin || state.isGameOver()) {
      didWin = true;
    }
    return didWin;
  }
}

class StatsEntry {
  double wins = 0;
  double attempts = 0;

  double winRate() {
    return wins / attempts;
  }
}