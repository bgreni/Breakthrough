import 'game_engine.dart';
import 'dart:math';

abstract class AI {
  Move selectMove(List<Move> legalMoves);
}


class RandomAI extends AI {
  Random rng = new Random();

  Move selectMove(List<Move> legalMoves) {
    return legalMoves[rng.nextInt(legalMoves.length)];
  }
}