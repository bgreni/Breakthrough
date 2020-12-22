import 'AI.dart';
import '../game_engine.dart';
import 'dart:math';


/// TODO: I'm not sure if this even counts as a proper flat mcts
class FlatMCTSAI extends AI {
  Stopwatch watch = new Stopwatch();
  static const int PLAYOUT_TIME = 1;
  int totalSimMoves = 0;
  int totalMovesMade = 0;

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
        // ++this.totalMovesMade;
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
      // ++this.totalSimMoves;
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
    return new PlayoutResult(turns, didWin);
  }

  double averageSimMoves() {
    return this.totalSimMoves.toDouble() / this.totalMovesMade.toDouble();
  }

}

class PlayoutResult {
  int numTurns;
  bool didWin;
  PlayoutResult(this.numTurns, this.didWin);
}