
import 'AI.dart';
import '../game_engine.dart';
import 'dart:math';

/// TODO: Same as flatmcts I'm not sure if this is done right, although this one gets destoyed by flat mcts so something is wrong
class UCTAI extends AI {

  Stopwatch watch = new Stopwatch();
  final int PLAYOUT_TIME = 1;


  String getName() {
    return "UCT";
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
}


class Node {
  int turn;
  State state;
  Node parent;
  List<Node> children;
  double wins = 0;
  double losses = 0;
  double visits = 0;
  bool expanded = false;
  final double EXPLOIT = sqrt2;

  Node(this.parent, this.turn, this.state) {
    this.children = <Node>[];
  }

  void expand() {
    for (Move move in state.getLegalMoves(this.turn)) {
      State s = state.copy();
      s.applyMove(move);
      children.add(new Node(this, s.turn, s));
    }
    expanded = true;
  }

  int playout(State state) {
    while (!state.isGameOver()) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[Random.secure().nextInt(moves.length)]);
    }
    return state.winner();
  }

  bool isTerminal() {
    return state.isGameOver();
  }

  int actualBestChild() {
    int bestChild = -1;
    double topScore = double.negativeInfinity;

    for (int i = 0; i < this.children.length; ++i) {
      double val = this.children[i].winRate();
      if (val > topScore)
        bestChild = i;
    }
    return bestChild;
  }

  int bestChild() {
    int bestChild = -1;
    double topScore = double.negativeInfinity;

    for (int i = 0; i < this.children.length; ++i) {
      double val = ucb(children[i]);
      if (val > topScore)
        bestChild = i;
    }
    return bestChild;
  }

  double ucb(Node child) {
    if (child.visits == 0) return double.infinity;
    return child.winRate() + EXPLOIT * sqrt(log(this.visits) / (child.visits));
  }

  double winRate() {
    return wins / visits;
  }

  void backProp(bool win) {
    if (!win) {
      ++this.losses;
    } else {
      ++this.wins;
    }
    ++this.visits;
    if (this.parent != null) {
      this.parent.backProp(win);
    }
  }

  bool allChildrenExpanded() {
    if (!this.expanded) return false;
    for (Node child in this.children) {
      if (!child.expanded) {
        return false;
      }
    }
    return true;
  }

  Node getUnexpandedChild() {
    List<Node> c = new List<Node>();

    for (Node child in this.children) {
      if (!child.expanded) c.add(child);
    }
    return c[Random.secure().nextInt(c.length)];
  }

}