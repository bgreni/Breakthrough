import 'AI.dart';
import '../game_engine.dart';


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