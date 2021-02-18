import 'dart:math';

import 'package:breakthrough/src/engine/ai_players.dart';
import 'package:breakthrough/src/engine/ai_players/wanderer_ai.dart';
import 'package:breakthrough/src/engine/game_engine.dart';
import 'package:breakthrough/src/engine/constants.dart' as C;

void main() {
  testAI();
  // bigTest();
}

void bigTest() {
  GameEngine engine = new GameEngine(1, 1, false);
  var allai = [
    new FlatMCTSAI(),
    new UCTAI(),
    new NegamaxAI(C.WANDERER_HEURISTIC),
    new NegamaxAI(C.ARTICLE_HEURISTIC),
    new RandomAI()
  ];
  var wins = {};
  for (var ai in allai) {
    wins[ai.getName()] = {};
    for (var ai2 in allai) {
      wins[ai.getName()][ai2.getName()] = 0;
    }
  }

  int counter = 0;
  int MAX_RERUNS = 1;

  for (var a1 in allai) {
    for (var a2 in allai) {
      if (a1.getName() != a2.getName()) {
        for (int i = 0; i < MAX_RERUNS; ++i) {
          var winner = engine.AIPlayout(a1, a2);
          var loser = winner == a1.getName() ? a2.getName() : a1.getName();
          wins[winner][loser] += 1;
          ++counter;
          print('\n Matches complete: $counter\n');
        }
      }
    }
  }
  for (var ai  in allai) {
    print('${ai.getName()} ${wins[ai.getName()]}');
  }

  var totalWins = {};
  for (var ai in allai) {
    totalWins[ai.getName()] = 0;
    for (var ai2 in allai) {
      totalWins[ai.getName()] += wins[ai.getName()][ai2.getName()];
    }
  }
  for (var ai  in allai) {
    print('${ai.getName()} ${totalWins[ai.getName()]}');
  }
}

void testAI() {
  final int MAX_ITERATIONS = 1;
  GameEngine engine = new GameEngine(1, 1, false);
  AI a1 = new FlatMCTSAI();
  // AI a2 = new UCTAI();
  // AI a2 = new WandererAI(C.WANDERER_HEURISTIC);
  // AI a1 = new NegamaxAI(C.ARTICLE_HEURISTIC);
  AI a2  = new NegamaxAI(C.WANDERER_HEURISTIC);
  Map<String, int> wins = {
    a1.getName(): 0,
    a2.getName(): 0
  };
  for (int i = 0; i < MAX_ITERATIONS; ++i) {
    String winner = engine.AIPlayout(a1, a2);
    wins[winner] += 1;
  }
  // print('Average moves to end in sims: ${a1.averageSimMoves()}');

  print('Total games: $MAX_ITERATIONS');
  print('${a1.getName()} wins: ${wins[a1.getName()]}');
  print('${a2.getName()} wins: ${wins[a2.getName()]}');

  // print('WINNER: $winner');
}