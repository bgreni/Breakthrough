import 'package:breakthrough/src/engine/ai_players/breakthrough_heuristic.dart';

import '../game_engine.dart';
import 'dart:math';
import '../constants.dart' as C;


class WandererNode extends BaseNode {
  double score = 0;
  double sum = 0;
  WandererHeuristic heuristic = new WandererHeuristic();
  final int SIM_CUTOFF_PROB = 2;

  WandererNode(WandererNode parent, int turn, State state) : super(parent, turn, state);

  @override
  void expand() {
    for (Move move in state.getLegalMoves(this.turn)) {
      State s = state.copy();
      s.applyMove(move);
      children.add(new WandererNode(this, s.turn, s));
    }
    expanded = true;
  }

  @override
  num playout(State state) {
    int max = state.turn;
    Random rand = Random.secure();
    while (!state.isGameOver() || rand.nextInt(100) < SIM_CUTOFF_PROB) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[rand.nextInt(moves.length)]);
    }
    return heuristic.evalHeuristic(state, max, State.opponent(max));
  }

  @override
  double getScore() {
    return this.score;
  }

  @override
  void backProp(PlayoutResult result) {
    ++this.visits;
    this.sum += result.boardScore;
    this.score = this.sum / this.visits;
    if (this.parent != null) {
      this.parent.backProp(result);
    }
  }
}


class UCTNode extends BaseNode {
  double wins = 0;
  double losses = 0;

  UCTNode(UCTNode parent, int turn, State state) : super(parent, turn, state);

  @override
  void expand() {
    for (Move move in state.getLegalMoves(this.turn)) {
      State s = state.copy();
      s.applyMove(move);
      children.add(new UCTNode(this, s.turn, s));
    }
    expanded = true;
  }

  @override
   num playout(State state) {
    while (!state.isGameOver()) {
      List<Move> moves = state.getLegalMoves(state.turn);
      if (moves.length == 0) {
        break;
      }
      state.applyMove(moves[Random.secure().nextInt(moves.length)]);
    }
    return state.winner();
  }

  @override
  double getScore() {
    return wins / visits;
  }

  @override
  void backProp(PlayoutResult result) {
    if (!result.isWin) {
      ++this.losses;
    } else {
      ++this.wins;
    }
    ++this.visits;
    if (this.parent != null) {
      this.parent.backProp(result);
    }
  }
}


abstract class BaseNode {
  int turn;
  State state;
  BaseNode parent;
  List<BaseNode> children;
  double visits = 0;
  bool expanded = false;
  final double EXPLOIT = sqrt2;

  BaseNode(this.parent, this.turn, this.state) {
    this.children = <BaseNode>[];
  }

  void expand();
  num playout(State state);
  double getScore();
  void backProp(PlayoutResult result);

  bool isTerminal() {
    return state.isGameOver();
  }

  int actualBestChild() {
    int bestChild = -1;
    double topScore = double.negativeInfinity;

    for (int i = 0; i < this.children.length; ++i) {
      double val = this.children[i].getScore();
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

  double ucb(BaseNode child) {
    if (child.visits == 0) return double.infinity;
    return child.getScore() + EXPLOIT * sqrt(log(this.visits) / (child.visits));
  }

  bool allChildrenExpanded() {
    if (!this.expanded) return false;
    for (BaseNode child in this.children) {
      if (!child.expanded) {
        return false;
      }
    }
    return true;
  }

  BaseNode getUnexpandedChild() {
    List<BaseNode> c = [];

    for (BaseNode child in this.children) {
      if (!child.expanded) c.add(child);
    }
    return c[Random.secure().nextInt(c.length)];
  }

}

class PlayoutResult {
  bool isWin;
  double boardScore;
  PlayoutResult(this.boardScore, {this.isWin=false});
}