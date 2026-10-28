import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/ai.dart';
import '../../domain/game/game_enums.dart';
import '../../domain/game/game_models.dart';
import '../../domain/game/rules.dart';
import 'app_state.dart';

const List<String> kOnlineOpponents = [
  'Rahim_BD',
  'Tanvir_Pro',
  'Shakib99',
  'Anik_Guti',
  'Tariqul_7',
  'Priya_Queen',
  'Sumon_Champa',
  'Niloy_Rider',
  'Farhan_Boss',
  'Sumi_Tiger',
  'Kabir_99',
  'Rafi_Champ',
  'Nafis_Ace',
];

class GameController extends ChangeNotifier {
  final Color? p1Color;
  final Color? p2Color;

  late final String? opponentName;
  late final int opponentAvatarIndex;
  String opponentPing = '36 ms';
  int opponentRating = 1350;

  GameController({
    required this.mode,
    required this.difficulty,
    this.p1Color,
    this.p2Color,
    String? opponentName,
    int? opponentAvatarIndex,
    String? opponentPing,
    int? opponentRating,
  }) {
    if (mode == Mode.online) {
      final rng = math.Random();
      this.opponentName = opponentName ??
          kOnlineOpponents[rng.nextInt(kOnlineOpponents.length)];
      this.opponentAvatarIndex =
          opponentAvatarIndex ?? rng.nextInt(kAvatars.length);
      this.opponentPing = opponentPing ?? '${24 + rng.nextInt(28)} ms';
      this.opponentRating = opponentRating ?? (1250 + rng.nextInt(250));
    } else {
      this.opponentName = opponentName;
      this.opponentAvatarIndex = opponentAvatarIndex ?? 0;
      this.opponentPing = opponentPing ?? '36 ms';
      this.opponentRating = opponentRating ?? 1300;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  GameController.restore(Map<String, dynamic> m, {this.p1Color, this.p2Color})
      : mode = Mode.values[
            ((m['mode'] as num?)?.toInt() ?? 0).clamp(0, Mode.values.length - 1)],
        difficulty = Difficulty.values[
            ((m['difficulty'] as num?)?.toInt() ?? 1).clamp(0, 2)] {
    opponentName = m['opponentName'] as String?;
    opponentAvatarIndex = (m['opponentAvatarIndex'] as num?)?.toInt() ?? 0;
    opponentPing = (m['opponentPing'] as String?) ?? '36 ms';
    opponentRating = (m['opponentRating'] as num?)?.toInt() ?? 1350;
    final b = List<int>.from((m['b'] as List).map((e) => (e as num).toInt()));
    final turn = (m['turn'] as num).toInt();
    final p1 = (m['p1'] as num).toInt();
    final p2 = (m['p2'] as num).toInt();
    final ply = (m['ply'] as num).toInt();
    state = GState(b, turn, p1, p2, ply);
    final rawPcs = m['pcs'] as List? ?? [];
    pcs.clear();
    int maxId = 0;
    for (final p in rawPcs) {
      final pid = (p['id'] as num).toInt();
      final player = (p['player'] as num).toInt();
      final node = (p['node'] as num).toInt();
      pcs.add(Pc(pid, player, node));
      if (pid >= maxId) maxId = pid + 1;
    }
    _nextId = maxId;
    seconds = (m['seconds'] as num?)?.toInt() ?? 0;
    idleLeft = (m['idleLeft'] as num?)?.toInt() ?? idleLimit;
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    if (isComputer(state.turn) || isAuto(state.turn)) {
      _runAi();
    }
  }

  /// Seconds a player may stay idle before auto mode plays for them.
  static const idleLimit = 15;

  final Mode mode;
  final Difficulty difficulty;
  GState state = GState.initial();
  final List<Pc> pcs = [
    Pc(0, 2, 0),
    Pc(1, 2, 1),
    Pc(2, 2, 2),
    Pc(3, 1, 6),
    Pc(4, 1, 7),
    Pc(5, 1, 8),
  ];
  final List<Snap> _hist = [];
  int _nextId = 6;
  Move? hintMove;

  List<Snap> get replayHistory => [
        ..._hist,
        Snap(state, pcs.map((p) => p.copy()).toList(), _nextId)
      ];
  int? selected;
  int pick = 0; // slider choice among [targets]
  Outcome outcome = Outcome.none;
  bool thinking = false;
  bool skipped = false;
  bool paused = false;
  int seconds = 0;
  int get elapsed => seconds;
  int idleLeft = idleLimit;
  final Map<int, bool> _auto = {1: false, 2: false};
  List<int>? winLine;
  GameResult? result;
  Timer? _timer;
  bool _disposed = false;
  int _token = 0; // invalidates pending computer / auto moves

  String get p1Name => app.displayName;
  String get p2Name {
    if (mode == Mode.online) {
      return opponentName ?? 'Opponent';
    }
    return mode == Mode.vsComputer ? tr('computer') : tr('player2');
  }

  bool isComputer(int p) =>
      (mode == Mode.vsComputer || mode == Mode.online) && p == 2;
  bool isAuto(int p) => _auto[p] ?? false;

  bool get canUndo =>
      outcome == Outcome.none && _hist.isNotEmpty && mode != Mode.online;

  bool get isOpponentThinking =>
      mode == Mode.online && state.turn == 2 && thinking;

  /// A human player's turn that the computer is playing for them.
  bool get autoActive =>
      outcome == Outcome.none &&
      !isComputer(state.turn) &&
      isAuto(state.turn);

  /// A human player's turn where the idle countdown is running.
  bool get counting =>
      outcome == Outcome.none &&
      app.autoEnabled &&
      !paused &&
      !isComputer(state.turn) &&
      !isAuto(state.turn);

  bool get isAutoWarning => counting && idleLeft <= 5;

  void cancelAutoTimer() {
    idleLeft = idleLimit;
    _auto[1] = false;
    _auto[2] = false;
    _token++;
    thinking = false;
    notifyListeners();
  }

  void computeHint() {
    final move = Ai.best(state, difficulty);
    hintMove = move;
    notifyListeners();
  }

  void clearHint() {
    hintMove = null;
    notifyListeners();
  }

  void pause() {
    if (outcome != Outcome.none || paused) return;
    paused = true;
    _token++;
    thinking = false;
    _timer?.cancel();
    saveToApp();
    notifyListeners();
  }

  void resume() {
    if (outcome != Outcome.none || !paused) return;
    paused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    if (isComputer(state.turn) || isAuto(state.turn)) {
      _runAi();
    }
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.index,
        'difficulty': difficulty.index,
        'b': List<int>.from(state.b),
        'turn': state.turn,
        'p1': state.p1,
        'p2': state.p2,
        'ply': state.ply,
        'pcs': pcs
            .map((p) => {'id': p.id, 'player': p.player, 'node': p.node})
            .toList(),
        'seconds': seconds,
        'idleLeft': idleLeft,
        'opponentName': opponentName,
        'opponentAvatarIndex': opponentAvatarIndex,
        'opponentPing': opponentPing,
        'opponentRating': opponentRating,
      };

  void saveToApp() {
    if (outcome == Outcome.none) {
      app.saveSession(toJson());
    } else {
      app.clearSession();
    }
  }

  void _tick(Timer t) {
    if (outcome != Outcome.none || _disposed || paused) return;
    seconds++;
    if (counting) {
      idleLeft--;
      if (idleLeft <= 0) {
        _auto[state.turn] = true; // switch this player to auto mode
        selected = null;
        _runAi();
        return;
      }
      notifyListeners();
    }
  }

  void restart() {
    app.clearSession();
    _token++;
    state = GState.initial();
    pcs
      ..clear()
      ..addAll([
        Pc(0, 2, 0),
        Pc(1, 2, 1),
        Pc(2, 2, 2),
        Pc(3, 1, 6),
        Pc(4, 1, 7),
        Pc(5, 1, 8),
      ]);
    _hist.clear();
    _nextId = 6;
    hintMove = null;
    selected = null;
    pick = 0;
    outcome = Outcome.none;
    thinking = false;
    skipped = false;
    paused = false;
    seconds = 0;
    idleLeft = idleLimit;
    _auto[1] = false;
    _auto[2] = false;
    winLine = null;
    result = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  // ───────── undo ─────────

  void _restore(Snap s) {
    state = s.state;
    pcs
      ..clear()
      ..addAll(s.pcs.map((p) => p.copy()));
    _nextId = s.nextId;
    hintMove = null;
  }

  /// Reverts the last move. Against the computer it goes back to your own
  /// previous turn (so both the computer's reply and your move are undone).
  void undo() {
    if (!canUndo) return;
    _token++;
    thinking = false;
    selected = null;
    hintMove = null;
    pick = 0;
    skipped = false;
    _restore(_hist.removeLast());
    if (mode == Mode.vsComputer) {
      while (state.turn != 1 && _hist.isNotEmpty) {
        _restore(_hist.removeLast());
      }
    }
    _auto[1] = false;
    _auto[2] = false;
    idleLeft = idleLimit;
    Sfx.play('undo');
    saveToApp();
    notifyListeners();
  }

  // ───────── input ─────────

  List<int> get targets {
    final s = selected;
    if (s == null) return const [];
    return Rules.adj[s].where((i) => state.b[i] == 0).toList();
  }

  /// Player [p] takes back control from auto mode.
  void takeOver(int p) {
    if (!isAuto(p)) return;
    _auto[p] = false;
    if (state.turn == p) {
      _token++;
      thinking = false;
      idleLeft = idleLimit;
    }
    notifyListeners();
  }

  void tap(int i) {
    if (outcome != Outcome.none) return;
    final t = state.turn;
    if (isComputer(t)) return;
    if (isAuto(t)) {
      // the player is playing again -> back to manual mode
      _auto[t] = false;
      _token++;
      thinking = false;
    }
    idleLeft = idleLimit;
    if (Rules.placed(state, t) < 3) {
      if (state.b[i] == 0) {
        _play(Move(-1, i));
        return;
      }
    } else {
      if (state.b[i] == t) {
        if (selected == i) {
          selected = null;
        } else {
          selected = i;
          pick = 0;
          Sfx.play('click');
        }
      } else if (selected != null &&
          state.b[i] == 0 &&
          Rules.adj[selected!].contains(i)) {
        final from = selected!;
        selected = null;
        hintMove = null;
        _play(Move(from, i));
        return;
      }
    }
    notifyListeners();
  }

  // mobile slider
  void setPick(int v) {
    pick = v;
    notifyListeners();
  }

  void cancelSelection() {
    selected = null;
    notifyListeners();
  }

  void moveToPicked() {
    if (outcome != Outcome.none) return;
    final t = state.turn;
    if (isComputer(t)) return;
    final tg = targets;
    if (selected == null || tg.isEmpty) return;
    final to = tg[pick.clamp(0, tg.length - 1)];
    final from = selected!;
    selected = null;
    hintMove = null;
    idleLeft = idleLimit;
    if (isAuto(t)) {
      _auto[t] = false;
      _token++;
      thinking = false;
    }
    _play(Move(from, to));
  }

  // ───────── moves ─────────

  void _applyMove(Move m) {
    _hist.add(Snap(state, pcs.map((p) => p.copy()).toList(), _nextId));
    if (m.from == -1) {
      pcs.add(Pc(_nextId++, state.turn, m.to));
    } else {
      pcs.firstWhere((p) => p.node == m.from && p.player == state.turn).node =
          m.to;
    }
    state = Rules.apply(state, m);
    selected = null;
    hintMove = null;
    Sfx.play('move');
  }

  void _play(Move m) {
    skipped = false;
    _applyMove(m);
    _afterMove();
  }

  void _afterMove() {
    final line = Rules.winLine(state.b);
    if (line != null) {
      winLine = line;
      _finish(state.b[line[0]] == 1 ? Outcome.p1 : Outcome.p2);
      return;
    }
    if (state.ply >= Ai.maxPly) {
      _finish(Outcome.draw);
      return;
    }
    if (Rules.moves(state).isEmpty) {
      state = Rules.pass(state);
      skipped = true;
      if (Rules.moves(state).isEmpty) {
        _finish(Outcome.draw);
        return;
      }
    }
    idleLeft = idleLimit;
    saveToApp();
    if (isComputer(state.turn) || isAuto(state.turn)) {
      _runAi();
    } else {
      notifyListeners();
    }
  }

  /// Plays a move for the current player (computer opponent, online opponent, or auto mode).
  void _runAi() {
    thinking = true;
    notifyListeners();
    final token = ++_token;

    final Duration delay;
    if (mode == Mode.online && state.turn == 2) {
      // Realistic human-like delay between 2.0s and 7.5s (strictly within 10s)
      final ms = 2000 + math.Random().nextInt(5500);
      delay = Duration(milliseconds: ms);
    } else {
      delay = const Duration(milliseconds: 750);
    }

    Future.delayed(delay, () {
      if (_disposed || token != _token || outcome != Outcome.none) return;
      final level = (mode == Mode.vsComputer || mode == Mode.online)
          ? difficulty
          : Difficulty.medium;
      final m = Ai.choose(state, level);
      thinking = false;
      skipped = false;
      _applyMove(m);
      _afterMove();
    });
  }

  void _finish(Outcome o) {
    app.clearSession();
    _token++;
    outcome = o;
    thinking = false;
    _timer?.cancel();
    var pts = 0;
    ResultKind kind;
    if (o == Outcome.p1) {
      kind = ResultKind.win;
    } else if (o == Outcome.p2) {
      kind = ResultKind.loss;
    } else {
      kind = ResultKind.draw;
    }
    if (mode == Mode.vsComputer || mode == Mode.online) {
      if (kind == ResultKind.win) {
        pts = mode == Mode.online
            ? 100
            : const {
                Difficulty.easy: 40,
                Difficulty.medium: 80,
                Difficulty.hard: 120
              }[difficulty]!;
      } else if (kind == ResultKind.draw) {
        pts = mode == Mode.online ? 25 : 10;
      }
    }
    int stars;
    if (o == Outcome.draw) {
      stars = 1;
    } else if (mode == Mode.twoPlayer) {
      stars = 3;
    } else if (o == Outcome.p2) {
      stars = 0;
    } else {
      stars = 1;
      if (difficulty != Difficulty.easy) stars++;
      if (state.ply <= 14) stars++;
    }

    final winner = o == Outcome.p1
        ? p1Name
        : o == Outcome.p2
            ? p2Name
            : tr('draw');
    final lvBefore = app.level;
    app.record(
        GameRecord(kind, mode, difficulty, pts, state.ply, seconds,
            mode == Mode.twoPlayer ? 0 : stars),
        winner);
    final unlocks = app.unlocksFor(lvBefore, app.level);
    result = GameResult(o, mode, difficulty, pts, state.ply, seconds, stars,
        p1Name, p2Name, unlocks);

    // sound
    if (o == Outcome.draw) {
      Sfx.play('draw');
    } else if ((mode == Mode.vsComputer || mode == Mode.online) &&
        o == Outcome.p2) {
      Sfx.play('lose');
    } else {
      Sfx.play('win');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _token++;
    _timer?.cancel();
    super.dispose();
  }
}

