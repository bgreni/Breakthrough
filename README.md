# Breakthrough

Mobile version of the board game breakthrough


Working off of the following two packages:
- A rework version of this chess engine to work for breakthrough https://github.com/davecom/chess.dart
- A modified version of this chess UI package to worth with breakthrough and the new engine https://github.com/deven98/flutter_chess_board
- Heuristice function based off of this article mhttps://www.codeproject.com/Articles/37024/Simple-AI-for-the-Game-of-Breakthrough

## Running AI vs AI playout
To test out AI agents against each other, edit the `testAI()` function in`test/engine_tests`
to use the two AI agents of your choosing. The run it using `dart run test/engine_tests.dart`
