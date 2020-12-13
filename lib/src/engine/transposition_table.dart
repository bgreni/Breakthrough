import 'dart:math';
import 'game_engine.dart';
import 'constants.dart' as C;

class TranspositionTable {
  Map<int, Entry> table = {};

  operator [](key) => table[key];

  bool contains(int h) {
    return table.containsKey(h);
  }

  double put(int h, double value, int depth) {
    Entry entry = new Entry(value, depth);
    table[h] = entry;
    return value;
  }

  Entry get(int h) {
    if (table.containsKey(h)) {
      return table[h];
    }
    return null;
  }
}

class Entry {
  double value;
  int depth;

  Entry(this.value, this.depth);
}

class ZobristHash {
  List<List<int>> table = new List.generate(C.TOTAL_TILES, (_) => new List(2));

  ZobristHash() {
    var rng = Random.secure();
    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      for (int j = 0; j < 2; ++j) {
        this.table[i][j] = rng.nextInt(C.INT32_MAX_VALUE);
      }
    }
  }

  int doHash(List<int> board) {
    int hash = 0;
    for (int i = 0; i < C.TOTAL_TILES; ++i) {
      int piece = board[i];
      if (piece != 0) {
        hash ^= table[i][piece - 1];
      }
    }
  }
}