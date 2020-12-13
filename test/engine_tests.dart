import 'dart:math';

import 'package:breakthrough/src/engine/AI.dart';
import 'package:breakthrough/src/engine/game_engine.dart';
import 'package:breakthrough/src/engine/constants.dart' as C;

void main() {
  testAI();
}

void testAI() {
  final int MAX_ITERATIONS = 1;
  GameEngine engine = new GameEngine(1);
  AI a1 = new FlatMCTSAI();
  AI a2  = new NegamaxAI();
  Map<String, int> wins = {
    a1.getName(): 0,
    a2.getName(): 0
  };
  for (int i = 0; i < MAX_ITERATIONS; ++i) {
    String winner = engine.AIPlayout(a1, a2);
    wins[winner] += 1;
  }

  print('Total games: $MAX_ITERATIONS');
  print('${a1.getName()} wins: ${wins[a1.getName()]}');
  print('${a2.getName()} wins: ${wins[a2.getName()]}');

  // print('WINNER: $winner');
}