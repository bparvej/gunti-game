import 'game_models.dart';

class Rules {
  static const adj = <List<int>>[
    [1, 3, 4],
    [0, 2, 4],
    [1, 4, 5],
    [0, 4, 6],
    [0, 1, 2, 3, 5, 6, 7, 8],
    [2, 4, 8],
    [3, 4, 7],
    [4, 6, 8],
    [4, 5, 7],
  ];

  static const lines = <List<int>>[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static List<int>? winLine(List<int> b) {
    for (final l in lines) {
      final v = b[l[0]];
      if (v != 0 && v == b[l[1]] && v == b[l[2]]) {
        // Player 1 cannot win on the bottom starting line [6, 7, 8].
        if (v == 1 && l[0] == 6 && l[1] == 7 && l[2] == 8) continue;
        // Player 2 cannot win on the top starting line [0, 1, 2].
        if (v == 2 && l[0] == 0 && l[1] == 1 && l[2] == 2) continue;
        return l;
      }
    }
    return null;
  }

  static int winner(List<int> b) {
    final l = winLine(b);
    return l == null ? 0 : b[l[0]];
  }

  static int checkWin(GState s) => winner(s.b);

  static int placed(GState s, int p) => p == 1 ? s.p1 : s.p2;

  static List<Move> legalMoves(GState s) {
    final res = <Move>[];
    for (var i = 0; i < 9; i++) {
      if (s.b[i] != s.turn) continue;
      for (final n in adj[i]) {
        if (s.b[n] == 0) res.add(Move(i, n));
      }
    }
    return res;
  }

  static List<Move> moves(GState s) => legalMoves(s);

  static GState apply(GState s, Move m) {
    final nb = List<int>.from(s.b);
    var p1 = s.p1, p2 = s.p2;
    if (m.from == -1) {
      nb[m.to] = s.turn;
      if (s.turn == 1) {
        p1++;
      } else {
        p2++;
      }
    } else {
      nb[m.from] = 0;
      nb[m.to] = s.turn;
    }
    return GState(nb, s.turn == 1 ? 2 : 1, p1, p2, s.ply + 1);
  }

  static GState pass(GState s) =>
      GState(s.b, s.turn == 1 ? 2 : 1, s.p1, s.p2, s.ply + 1);
}

