
import 'AI.dart';
import '../game_engine.dart';
import 'dart:math';
import 'node.dart';

/// TODO: Same as flatmcts I'm not sure if this is done right, although this one gets destoyed by flat mcts so something is wrong
class UCTAI extends AI {

  Stopwatch watch = new Stopwatch();
  final int PLAYOUT_TIME = 1;


  String getName() {
    return "UCT";
  }

  Move selectMove(List<Move> legalMoves, State state) {
    UCTNode root = new UCTNode(null, state.turn, state.copy());

    int counter = 0;
    watch.reset();
    watch.start();
    while (watch.elapsed.inSeconds < PLAYOUT_TIME) {
      UCTNode node = root;

      while (node.allChildrenExpanded()) {
        node = node.children[node.bestChild()];
      }

      if (node.expanded) {
        node = node.getUnexpandedChild();
      } else {
        node.expand();
      }

      int result = node.playout(node.state.copy());
      node.backProp(new PlayoutResult(0, isWin: result == root.turn));

      ++counter;
    }
    watch.stop();
    print('Sims completed $counter');
    return legalMoves[root.actualBestChild()];
  }
}