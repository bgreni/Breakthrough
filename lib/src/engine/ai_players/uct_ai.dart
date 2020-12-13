import 'AI.dart';
import '../game_engine.dart';
import 'dart:math';

/// TODO: Same as flatmcts I'm not sure if this is done right, although this one gets destoyed by flat mcts so something is wrong
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
    if (wantWin == state.winner()) {
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