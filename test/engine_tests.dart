import 'package:breakthrough/src/AI.dart';
import 'package:breakthrough/src/game_engine.dart';
import 'package:breakthrough/src/constants.dart' as C;

void main() {
  testAI();
}

void testAI() {
  GameEngine engine = new GameEngine();
  AI a1 = new NegamaxAI();
  AI a2  = new FlatMCTSAI();
  String winner = engine.AIPlayout(a1, a2) == C.WHITE ? a1.getName() : a2.getName();
  print('WINNER: $winner');
}