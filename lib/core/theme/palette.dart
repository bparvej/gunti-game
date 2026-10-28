import 'package:flutter/material.dart';

Color fade(Color c, double o) => c.withAlpha((o * 255).round());

String fmtTime(int s) =>
    '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

String fmtNum(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

class RibbonColors {
  final Color top, bottom, tail, outline;
  const RibbonColors(this.top, this.bottom, this.tail, this.outline);
}

class AvatarData {
  final String id;
  final String emoji;
  final String name;
  final Color bg1, bg2, border;
  final int price;
  const AvatarData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.bg1,
    required this.bg2,
    required this.border,
    this.price = 0,
  });
}

const kAvatars = [
  AvatarData(
    id: 'tiger',
    emoji: '🐯',
    name: 'Bengal Tiger',
    bg1: Color(0xFFFFB300),
    bg2: Color(0xFFF57C00),
    border: Color(0xFFD84315),
    price: 0,
  ),
  AvatarData(
    id: 'king',
    emoji: '👑',
    name: 'Royal King',
    bg1: Color(0xFFFFE082),
    bg2: Color(0xFFFFB300),
    border: Color(0xFFFFA000),
    price: 100,
  ),
  AvatarData(
    id: 'lion',
    emoji: '🦁',
    name: 'Golden Lion',
    bg1: Color(0xFFFFCC80),
    bg2: Color(0xFFFF9800),
    border: Color(0xFFE65100),
    price: 120,
  ),
  AvatarData(
    id: 'eagle',
    emoji: '🦅',
    name: 'Thunder Eagle',
    bg1: Color(0xFF81D4FA),
    bg2: Color(0xFF0288D1),
    border: Color(0xFF01579B),
    price: 150,
  ),
  AvatarData(
    id: 'ninja',
    emoji: '🥷',
    name: 'Shadow Ninja',
    bg1: Color(0xFFB0BEC5),
    bg2: Color(0xFF455A64),
    border: Color(0xFF263238),
    price: 180,
  ),
  AvatarData(
    id: 'wizard',
    emoji: '🧙',
    name: 'Mystic Mage',
    bg1: Color(0xFFCE93D8),
    bg2: Color(0xFF8E24AA),
    border: Color(0xFF4A148C),
    price: 200,
  ),
  AvatarData(
    id: 'robot',
    emoji: '🤖',
    name: 'Cyber Bot',
    bg1: Color(0xFF80DEEA),
    bg2: Color(0xFF00ACC1),
    border: Color(0xFF006064),
    price: 220,
  ),
  AvatarData(
    id: 'fox',
    emoji: '🦊',
    name: 'Clever Fox',
    bg1: Color(0xFFFFAB91),
    bg2: Color(0xFFFF5722),
    border: Color(0xFFBF360C),
    price: 250,
  ),
  AvatarData(
    id: 'pilot',
    emoji: '🚀',
    name: 'Cosmic Pilot',
    bg1: Color(0xFF9FA8DA),
    bg2: Color(0xFF3F51B5),
    border: Color(0xFF1A237E),
    price: 280,
  ),
  AvatarData(
    id: 'dragon',
    emoji: '🐉',
    name: 'Fire Dragon',
    bg1: Color(0xFFA5D6A7),
    bg2: Color(0xFF43A047),
    border: Color(0xFF1B5E20),
    price: 300,
  ),
];

class CoinColorOption {
  final String name;
  final Color primary;
  final Color secondary;
  final Color dark;
  final Color opponentColor;
  final int price;

  const CoinColorOption({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.dark,
    required this.opponentColor,
    this.price = 0,
  });
}

const kCoinColors = [
  CoinColorOption(
    name: 'Purple',
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF9333EA),
    dark: Color(0xFF5B21B6),
    opponentColor: Color(0xFFFF8A65),
    price: 0,
  ),
  CoinColorOption(
    name: 'Royal Blue',
    primary: Color(0xFF1E88E5),
    secondary: Color(0xFF29B6F6),
    dark: Color(0xFF1565C0),
    opponentColor: Color(0xFFFFB300),
    price: 150,
  ),
  CoinColorOption(
    name: 'Emerald Green',
    primary: Color(0xFF43A047),
    secondary: Color(0xFF66BB6A),
    dark: Color(0xFF2E7D32),
    opponentColor: Color(0xFFE53935),
    price: 250,
  ),
  CoinColorOption(
    name: 'Sunset Gold',
    primary: Color(0xFFFFB300),
    secondary: Color(0xFFFFCA28),
    dark: Color(0xFFF57C00),
    opponentColor: Color(0xFF7C3AED),
    price: 350,
  ),
  CoinColorOption(
    name: 'Ruby Red',
    primary: Color(0xFFE53935),
    secondary: Color(0xFFEF5350),
    dark: Color(0xFFC62828),
    opponentColor: Color(0xFF1E88E5),
    price: 500,
  ),
  CoinColorOption(
    name: 'Teal Cyan',
    primary: Color(0xFF00ACC1),
    secondary: Color(0xFF26C6DA),
    dark: Color(0xFF00838F),
    opponentColor: Color(0xFFFF7043),
    price: 600,
  ),
];

class Pal {
  final Color bg1, bg2, card, text, sub, soft, nav, primary, border, line;
  final Color me, opp, greenFill;
  final int unlock;

  const Pal({
    required this.bg1,
    required this.bg2,
    required this.card,
    required this.text,
    required this.sub,
    required this.soft,
    required this.nav,
    required this.primary,
    required this.border,
    required this.line,
    required this.me,
    required this.opp,
    required this.greenFill,
    required this.unlock,
  });

  static const green = Color(0xFF7EE08A);
  static const greenDark = Color(0xFF4FBF5E);
  static const gold = Color(0xFFFFC53D);

  /// 0 – Purple Dream (default)
  static const purple = Pal(
    bg1: Color(0xFF7B3FE4),
    bg2: Color(0xFF6224C9),
    card: Colors.white,
    text: Color(0xFF1F1B3A),
    sub: Color(0xFF8A86A3),
    soft: Color(0xFFF3EEFF),
    nav: Color(0xFF4B1D9C),
    primary: Color(0xFF6D28D9),
    border: Color(0xFFE5E1F2),
    line: Color(0xFFCBBDF2),
    me: Color(0xFF7C3AED),
    opp: Color(0xFFFF8A65),
    greenFill: Color(0xFFE3F9E6),
    unlock: 1,
  );

  /// 1 – Classic Light: white cards, black text, black vs red pieces
  static const classic = Pal(
    bg1: Color(0xFF5B6B8A),
    bg2: Color(0xFF475673),
    card: Colors.white,
    text: Color(0xFF111111),
    sub: Color(0xFF6B7280),
    soft: Color(0xFFF1F3F7),
    nav: Color(0xFF2F3A52),
    primary: Color(0xFF3B4B6B),
    border: Color(0xFFE3E6EC),
    line: Color(0xFFC5CCD9),
    me: Color(0xFF263238),
    opp: Color(0xFFE53935),
    greenFill: Color(0xFFE3F9E6),
    unlock: 2,
  );

  /// 2 – Dark Mode
  static const dark = Pal(
    bg1: Color(0xFF1C1040),
    bg2: Color(0xFF120A2E),
    card: Color(0xFF261A4A),
    text: Color(0xFFEDE8FF),
    sub: Color(0xFFA39BC8),
    soft: Color(0xFF32245E),
    nav: Color(0xFF0C0620),
    primary: Color(0xFF8B5CF6),
    border: Color(0xFF3B2D6B),
    line: Color(0xFF4C3E85),
    me: Color(0xFFA78BFA),
    opp: Color(0xFFFF8A65),
    greenFill: Color(0xFF1F4A3A),
    unlock: 3,
  );

  /// 3 – Ocean Blue
  static const ocean = Pal(
    bg1: Color(0xFF1AB6D6),
    bg2: Color(0xFF0C7FA3),
    card: Colors.white,
    text: Color(0xFF083344),
    sub: Color(0xFF5B8A99),
    soft: Color(0xFFE0F7FA),
    nav: Color(0xFF064B63),
    primary: Color(0xFF0891B2),
    border: Color(0xFFCDECF2),
    line: Color(0xFF9FDDE9),
    me: Color(0xFF0369A1),
    opp: Color(0xFFFF7A59),
    greenFill: Color(0xFFE3F9E6),
    unlock: 5,
  );

  /// 4 – Sunset Gold
  static const sunset = Pal(
    bg1: Color(0xFFFFA23F),
    bg2: Color(0xFFE8601F),
    card: Colors.white,
    text: Color(0xFF3B1D0A),
    sub: Color(0xFF9A7B66),
    soft: Color(0xFFFFF1E0),
    nav: Color(0xFF8A3410),
    primary: Color(0xFFEA580C),
    border: Color(0xFFF3DFCB),
    line: Color(0xFFFBCB98),
    me: Color(0xFFE59A00),
    opp: Color(0xFFB91C1C),
    greenFill: Color(0xFFE3F9E6),
    unlock: 7,
  );

  static const themes = [purple, classic, dark, ocean, sunset];
}

typedef ThemeIndexProvider = int Function();
ThemeIndexProvider currentThemeIndex = () => 0;

Pal get pal =>
    Pal.themes[currentThemeIndex().clamp(0, Pal.themes.length - 1)];

