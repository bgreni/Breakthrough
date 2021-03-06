import 'AI.dart';
import '../game_engine.dart';


/// Negamax player using iterative deepening
/// TODO: I think the algorithm is implemented correctly, but my heuristic sucks so it doesn't play very well possibly pruning too hard because it runs way too fast
class NegamaxAI extends AI {
  int maxDepth = 10;
  bool searchedFullTree = true;
  int maxSeconds = 1;
  Stopwatch watch = new Stopwatch();
  String heuristicType;

  NegamaxAI(String heuristicType) : super(heuristicType) {
    this.heuristicType = heuristicType;
  }


  String getName() {
    return "Negamax : $heuristicType";
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
    Move bestMoveCompleted;

    while (searchDepth < this.maxDepth) {
      ++searchDepth;

      double score = AI.ALPHA_INIT;
      double alpha = AI.ALPHA_INIT;
      double beta = AI.BETA_INIT;
      double value;

      searchedFullTree = true;

      for (int i = 0; i < numRootMoves; ++i) {
        State copyState = state.copy();
        Move m = legalMoves[i];
        copyState.applyMove(m);
        value = -negamax(copyState, searchDepth-1, -beta, -alpha, State.opponent(state.turn));
        // moveScores[i] = value;
        if (shouldStop()) {
          bestMove = null;
          break;
        }

        if (value > score) {
          // print('value: $value : score: $score');
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
        } else if (searchedFullTree) {
          print(
              'Completed search of depth $searchDepth (no proven win or loss');
        } else {
          bestMoveCompleted = bestMove;
        }
      }
      // } else {
      //   --searchDepth;
      // }

      if (shouldStop()) break;

      // legalMoves.sort((m1, m2) => moveScores[legalMoves.indexOf(m1)].compareTo(moveScores[legalMoves.indexOf(m2)]));
      // moveScores = {};
    }
    print('Completed search of depth $searchDepth');
    return bestMoveCompleted;
  }

  double negamax(State state, int depth, double alpha, double beta, int maximisingPlayer) {

    // int hash = hasher.doHash(state.board.board);
    //
    // if (tt.contains(hash) && tt[hash].depth >= depth) {
    //   return tt[hash].value;
    // }
    if (state.isGameOver()) {
      return staticallyEvaluate(state, maximisingPlayer);
    }

    if (depth == 0 || shouldStop()) {
      double eval = staticallyEvaluate(state, maximisingPlayer);
      searchedFullTree = false;
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
      value = -negamax(copyState, depth - 1, -beta, -alpha, State.opponent(maximisingPlayer));


      if (shouldStop()) break;;

      if (value > alpha) {
        alpha = value;
      }

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