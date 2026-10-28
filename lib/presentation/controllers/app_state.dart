import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/audio/sfx.dart';
import '../../core/constants/strings.dart';
import '../../core/storage/store.dart';
import '../../core/theme/palette.dart';
import '../../domain/game/game_enums.dart';
import '../../domain/game/game_models.dart';

class AppState extends ChangeNotifier {
  String name = '';
  Difficulty difficulty = Difficulty.medium;
  AppLanguage language = AppLanguage.english;
  int themeIndex = 0;
  GutiShape shape = GutiShape.round;
  int avatarIndex = 0;
  int coinColorIndex = 0;
  bool soundOn = true;
  bool vibrationOn = true;
  bool onboarded = false;
  bool autoEnabled = true;
  bool hasSeenTutorial = false;

  Color get playerCoinColor =>
      kCoinColors[coinColorIndex.clamp(0, kCoinColors.length - 1)].primary;
  Color get opponentCoinColor =>
      kCoinColors[coinColorIndex.clamp(0, kCoinColors.length - 1)].opponentColor;

  final Set<int> unlockedThemes = {0};
  final Set<int> unlockedShapes = {0};
  final Set<int> unlockedAvatars = {0};
  final Set<int> unlockedCoins = {0};
  String? lastBonusDate;

  // lifetime stats (persisted)
  int points = 0, wins = 0, losses = 0, draws = 0, totalStars = 0;
  int totalMoves = 0, curStreak = 0, bestStreak = 0;
  bool beatHard = false;
  String lastWinner = '';

  // this session only
  int sessionP1 = 0, sessionP2 = 0;
  final List<GameRecord> history = [];
  Map<String, dynamic>? activeSession;

  bool get hasActiveSession => activeSession != null;

  AppState() {
    _bindProviders();
  }

  void _bindProviders() {
    currentLanguage = () => language;
    currentThemeIndex = () => themeIndex;
    isSoundEnabled = () => soundOn;
  }

  void haptic() {
    if (!vibrationOn) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  void saveSession(Map<String, dynamic>? s) {
    activeSession = s;
    notifyListeners();
  }

  void clearSession() {
    if (activeSession != null) {
      activeSession = null;
      notifyListeners();
    }
  }

  /// Level needed for each guti shape (round, square, broom).
  static const shapeUnlock = [1, 4, 6];

  String get displayName => name.trim().isEmpty ? 'Player 1' : name.trim();
  String get initial => displayName.substring(0, 1).toUpperCase();

  void set(void Function() change) {
    change();
    _bindProviders();
    notifyListeners();
  }

  // ---- persistence ----
  void load() {
    final raw = Store.read();
    if (raw == null) {
      if (!themeUnlocked(themeIndex)) themeIndex = 0;
      if (!shapeUnlocked(shape)) shape = GutiShape.round;
      if (!isAvatarUnlocked(avatarIndex)) avatarIndex = 0;
      if (!isCoinUnlocked(coinColorIndex)) coinColorIndex = 0;
      return;
    }
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      int i(String k, int d) => (m[k] as num?)?.toInt() ?? d;
      name = (m['name'] as String?) ?? '';
      difficulty = Difficulty.values[i('difficulty', 1).clamp(0, 2)];
      language = AppLanguage.values[i('language', 0).clamp(0, 1)];
      themeIndex = i('theme', 0).clamp(0, Pal.themes.length - 1);
      shape = GutiShape.values[i('shape', 0).clamp(0, 2)];
      avatarIndex = i('avatar', 0).clamp(0, kAvatars.length - 1);
      coinColorIndex = i('coinColor', 0).clamp(0, kCoinColors.length - 1);
      soundOn = (m['sound'] as bool?) ?? true;
      vibrationOn = (m['vibration'] as bool?) ?? true;
      onboarded = (m['onboarded'] as bool?) ?? false;
      autoEnabled = (m['auto'] as bool?) ?? true;
      hasSeenTutorial = (m['tutorial'] as bool?) ?? false;
      lastBonusDate = m['bonusDate'] as String?;
      points = i('points', 0);
      wins = i('wins', 0);
      losses = i('losses', 0);
      draws = i('draws', 0);
      totalStars = i('stars', 0);
      totalMoves = i('moves', 0);
      curStreak = i('streak', 0);
      bestStreak = i('best', 0);
      beatHard = (m['hard'] as bool?) ?? false;
      lastWinner = (m['last'] as String?) ?? '';
      if (m['history'] is List) {
        history.clear();
        for (final item in (m['history'] as List)) {
          if (item is Map) {
            history.add(GameRecord(
              ResultKind.values[(item['kind'] as num?)?.toInt().clamp(0, 2) ?? 0],
              Mode.values[(item['mode'] as num?)?.toInt().clamp(0, Mode.values.length - 1) ?? 0],
              Difficulty.values[(item['diff'] as num?)?.toInt().clamp(0, 2) ?? 1],
              (item['pts'] as num?)?.toInt() ?? 0,
              (item['moves'] as num?)?.toInt() ?? 0,
              (item['secs'] as num?)?.toInt() ?? 0,
              (item['stars'] as num?)?.toInt() ?? 0,
            ));
          }
        }
      }
      if (m.containsKey('session') && m['session'] != null) {
        activeSession = Map<String, dynamic>.from(m['session'] as Map);
      }
      if (m['unlockedThemes'] is List) {
        unlockedThemes.addAll(
            (m['unlockedThemes'] as List).map((e) => (e as num).toInt()));
      }
      if (m['unlockedShapes'] is List) {
        unlockedShapes.addAll(
            (m['unlockedShapes'] as List).map((e) => (e as num).toInt()));
      }
      if (m['unlockedAvatars'] is List) {
        unlockedAvatars.addAll(
            (m['unlockedAvatars'] as List).map((e) => (e as num).toInt()));
      }
      unlockedAvatars.add(0);
      if (m['unlockedCoins'] is List) {
        unlockedCoins.addAll(
            (m['unlockedCoins'] as List).map((e) => (e as num).toInt()));
      }
      unlockedCoins.add(0);
      if (!themeUnlocked(themeIndex)) themeIndex = 0;
      if (!shapeUnlocked(shape)) shape = GutiShape.round;
      if (!isAvatarUnlocked(avatarIndex)) avatarIndex = 0;
      if (!isCoinUnlocked(coinColorIndex)) coinColorIndex = 0;
      _bindProviders();
    } catch (_) {}
  }

  void _save() {
    Store.write(jsonEncode({
      'name': name,
      'difficulty': difficulty.index,
      'language': language.index,
      'theme': themeIndex,
      'shape': shape.index,
      'avatar': avatarIndex,
      'coinColor': coinColorIndex,
      'sound': soundOn,
      'vibration': vibrationOn,
      'onboarded': onboarded,
      'auto': autoEnabled,
      'tutorial': hasSeenTutorial,
      'bonusDate': lastBonusDate,
      'unlockedThemes': unlockedThemes.toList(),
      'unlockedShapes': unlockedShapes.toList(),
      'unlockedAvatars': unlockedAvatars.toList(),
      'unlockedCoins': unlockedCoins.toList(),
      'points': points,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'stars': totalStars,
      'moves': totalMoves,
      'streak': curStreak,
      'best': bestStreak,
      'hard': beatHard,
      'last': lastWinner,
      'session': activeSession,
      'history': history.map((e) => {
        'kind': e.kind.index,
        'mode': e.mode.index,
        'diff': e.difficulty.index,
        'pts': e.points,
        'moves': e.moves,
        'secs': e.seconds,
        'stars': e.stars,
      }).toList(),
    }));
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    _save();
  }

  // ---- game results ----
  void record(GameRecord r, String winner) {
    history.insert(0, r);
    points += r.points;
    totalStars += r.stars;
    totalMoves += r.moves;
    lastWinner = winner;
    switch (r.kind) {
      case ResultKind.win:
        wins++;
        sessionP1++;
        curStreak++;
        bestStreak = math.max(bestStreak, curStreak);
        if (r.mode == Mode.vsComputer && r.difficulty == Difficulty.hard) {
          beatHard = true;
        }
        break;
      case ResultKind.loss:
        losses++;
        sessionP2++;
        curStreak = 0;
        break;
      case ResultKind.draw:
        draws++;
        curStreak = 0;
        break;
    }
    notifyListeners();
  }

  // ---- levels & unlocks ----
  int get level => points ~/ 100 + 1;
  double get levelProgress => (points % 100) / 100;

  bool themeUnlocked(int i) =>
      i == 0 || unlockedThemes.contains(i) || level >= Pal.themes[i].unlock;

  bool shapeUnlocked(GutiShape s) =>
      s == GutiShape.round ||
      unlockedShapes.contains(s.index) ||
      level >= shapeUnlock[s.index];

  bool buyTheme(int i, int cost) {
    if (points < cost) return false;
    points -= cost;
    unlockedThemes.add(i);
    themeIndex = i;
    _bindProviders();
    notifyListeners();
    return true;
  }

  bool buyShape(GutiShape s, int cost) {
    if (points < cost) return false;
    points -= cost;
    unlockedShapes.add(s.index);
    shape = s;
    notifyListeners();
    return true;
  }

  bool isAvatarUnlocked(int idx) => idx == 0 || unlockedAvatars.contains(idx);

  bool buyAvatar(int idx) {
    if (idx < 0 || idx >= kAvatars.length) return false;
    final price = kAvatars[idx].price;
    if (isAvatarUnlocked(idx)) {
      avatarIndex = idx;
      notifyListeners();
      return true;
    }
    if (points < price) return false;
    points -= price;
    unlockedAvatars.add(idx);
    avatarIndex = idx;
    notifyListeners();
    return true;
  }

  bool isCoinUnlocked(int idx) => idx == 0 || unlockedCoins.contains(idx);

  bool buyCoin(int idx) {
    if (idx < 0 || idx >= kCoinColors.length) return false;
    final cost = kCoinColors[idx].price;
    if (isCoinUnlocked(idx)) {
      coinColorIndex = idx;
      _save();
      notifyListeners();
      return true;
    }
    if (points < cost) return false;
    points -= cost;
    unlockedCoins.add(idx);
    coinColorIndex = idx;
    _save();
    notifyListeners();
    return true;
  }

  bool get canClaimDailyBonus {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastBonusDate != today;
  }

  bool claimDailyBonus([int bonus = 100]) {
    if (!canClaimDailyBonus) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    lastBonusDate = today;
    points += bonus;
    notifyListeners();
    return true;
  }

  /// Names of things unlocked when going from level [from] to level [to].
  List<String> unlocksFor(int from, int to) {
    final out = <String>[];
    for (var i = 0; i < Pal.themes.length; i++) {
      final u = Pal.themes[i].unlock;
      if (u > from && u <= to) out.add('${tr('theme')}: ${tr('th$i')}');
    }
    for (final s in GutiShape.values) {
      final u = shapeUnlock[s.index];
      if (u > from && u <= to) out.add('${tr('shape')}: ${tr('sh${s.index}')}');
    }
    return out;
  }

  /// Lowest level that still unlocks something new (null when all unlocked).
  int? get nextUnlockLevel {
    int? best;
    for (final t in Pal.themes) {
      if (t.unlock > level && (best == null || t.unlock < best)) {
        best = t.unlock;
      }
    }
    for (final u in shapeUnlock) {
      if (u > level && (best == null || u < best)) best = u;
    }
    return best;
  }

  // ---- leaderboard ----
  static const _bots = [
    LeaderEntry('Jackson Kim', 2875, avatarIndex: 1),
    LeaderEntry('Kendal Coleman', 2589, avatarIndex: 2),
    LeaderEntry('Kelin Harward', 2166, avatarIndex: 3),
    LeaderEntry('James Haydon', 2086, avatarIndex: 4),
    LeaderEntry('Emili Williamson', 1980, avatarIndex: 5),
    LeaderEntry('Jessica Taylor', 1640, avatarIndex: 6),
    LeaderEntry('Rafi Ahmed', 1210, avatarIndex: 7),
    LeaderEntry('Nusrat Jahan', 980, avatarIndex: 8),
    LeaderEntry('Tanvir Hasan', 760, avatarIndex: 9),
  ];

  List<LeaderEntry> board() {
    final list = [
      ..._bots,
      LeaderEntry(displayName, points, isYou: true, avatarIndex: avatarIndex)
    ];
    list.sort((a, b) {
      final c = b.points.compareTo(a.points);
      if (c != 0) return c;
      if (a.isYou != b.isYou) return a.isYou ? 1 : -1;
      return 0;
    });
    return list;
  }

  int get rank => board().indexWhere((e) => e.isYou) + 1;
  int get games => wins + losses + draws;
  int get winRate => games == 0 ? 0 : (wins * 100 / games).round();
  int get avgMoves => games == 0 ? 0 : (totalMoves / games).round();
}

final app = AppState();

Widget appBuilder(WidgetBuilder b) =>
    ListenableBuilder(listenable: app, builder: (c, _) => b(c));

