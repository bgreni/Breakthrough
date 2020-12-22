import 'AI.dart';
import '../game_engine.dart';
import 'uct_ai.dart';
import 'dart:math';

/// Based off of the AI player described in this paper https://scholarworks.calstate.edu/downloads/1z40kw957


class WandererAI extends AI {

  Stopwatch watch = new Stopwatch();
  final int PLAYOUT_TIME = 1;
  final int MAX_DEPTH = 10;

  WandererAI(String heuristicType) : super(heuristicType);

  String getName() {
    return 'Wanderer';
  }

  Move selectMove(List<Move> legalMoves, State state) {
    Node root = new Node(null, state.turn, state.copy());

    int counter = 0;
    watch.reset();
    watch.start();
    while (watch.elapsed.inSeconds < PLAYOUT_TIME) {
      Node node = root;

      while (node.allChildrenExpanded()) {
        node = node.children[node.bestChild()];
      }

      if (node.expanded) {
        node = node.getUnexpandedChild();
      } else {
        node.expand();
      }

      int result = node.playout(node.state.copy());
      node.backProp(result == root.turn);

      ++counter;
    }
    watch.stop();
    print('Sims completed $counter');
    return legalMoves[root.actualBestChild()];
  }

  double playout(State state) {
    int maxPlayer = state.turn;
    int depth = 0;
    while (!state.isGameOver() || depth < MAX_DEPTH) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[Random.secure().nextInt(moves.length)]);
      ++depth;
    }
    return staticallyEvaluate(state, maxPlayer);
  }
}