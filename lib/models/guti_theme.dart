import 'package:flutter/material.dart';

class GutiTheme {
  final String name;
  final Color backgroundColor;
  final int boardLineColor;
  final Color redColor;
  final Color blueColor;
  final String textColor;
  final Color hintColor;

  const GutiTheme({
    required this.name,
    required this.backgroundColor,
    required this.boardLineColor,
    required this.redColor,
    required this.blueColor,
    required this.textColor,
    required this.hintColor,
  });
}

class GutiShape {
  final String id;
  final String label;

  const GutiShape({required this.id, required this.label});

  static const values = [
    GutiShape(id: 'circle', label: 'Circle'),
    GutiShape(id: 'square', label: 'Square'),
    GutiShape(id: 'bar', label: 'Stick'),
    GutiShape(id: 'lalbadshah', label: 'Lal Badshah'),
  ];
}

class BackgroundTheme {
  final String id;
  final String label;
  final IconData icon;

  const BackgroundTheme({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const values = [
    BackgroundTheme(id: 'teakwood', label: 'Teak Wood', icon: Icons.square_foot),
    BackgroundTheme(id: 'velvet', label: 'Velvet Red', icon: Icons.favorite),
    BackgroundTheme(id: 'greenmat', label: 'Green Mat', icon: Icons.eco),
    BackgroundTheme(id: 'night', label: 'Moonlit Night', icon: Icons.nightlight),
    BackgroundTheme(id: 'marble', label: 'Marble', icon: Icons.square_foot),
    BackgroundTheme(id: 'dino', label: 'Funny Dino', icon: Icons.toys),
    BackgroundTheme(id: 'upload', label: 'Upload from Device', icon: Icons.upload),
  ];
}

class ColorPair {
  final String name;
  final Color p1;
  final Color p2;

  const ColorPair({
    required this.name,
    required this.p1,
    required this.p2,
  });
}

class GameConfig {
  static const themes = [
    GutiTheme(
      name: 'Classic Light',
      backgroundColor: Color(0xFFFFFFFF),
      boardLineColor: 0xFF000000,
      redColor: Color(0xFFFF0000),
      blueColor: Color(0xFF0000FF),
      textColor: '#000000',
      hintColor: Color(0xFF00FF00),
    ),
    GutiTheme(
      name: 'Dark Mode',
      backgroundColor: Color(0xFF1A1A1A),
      boardLineColor: 0xFFFFFFFF,
      redColor: Color(0xFFFF5252),
      blueColor: Color(0xFF00E676),
      textColor: '#FFFFFF',
      hintColor: Color(0xFF00E676),
    ),
    GutiTheme(
      name: 'Ocean Blue',
      backgroundColor: Color(0xFFE0F2F1),
      boardLineColor: 0xFF00695C,
      redColor: Color(0xFFFF5252),
      blueColor: Color(0xFF00BCD4),
      textColor: '#004D40',
      hintColor: Color(0xFF4CAF50),
    ),
    GutiTheme(
      name: 'Sunset Gold',
      backgroundColor: Color(0xFFFFF8E1),
      boardLineColor: 0xFFD4AC6F,
      redColor: Color(0xFFE65100),
      blueColor: Color(0xFF1976D2),
      textColor: '#BF360C',
      hintColor: Color(0xFFF9A825),
    ),
    GutiTheme(
      name: 'Purple Dream',
      backgroundColor: Color(0xFFF3E5F5),
      boardLineColor: 0xFF4A148C,
      redColor: Color(0xFFD5006D),
      blueColor: Color(0xFF40C4FF),
      textColor: '#4A148C',
      hintColor: Color(0xFFB2FF59),
    ),
  ];

  static const colorPairs = [
    ColorPair(name: 'Classic', p1: Color(0xFFFF0000), p2: Color(0xFF0000FF)),
    ColorPair(name: 'Sunset', p1: Color(0xFFFF5252), p2: Color(0xFF40C4FF)),
    ColorPair(name: 'Forest', p1: Color(0xFFFF9800), p2: Color(0xFF4CAF50)),
    ColorPair(name: 'Berry', p1: Color(0xFFE91E63), p2: Color(0xFF9C27B0)),
    ColorPair(name: 'Ocean', p1: Color(0xFFFFEB3B), p2: Color(0xFF03A9F4)),
    ColorPair(name: 'Royal', p1: Color(0xFFD32F2F), p2: Color(0xFF303F9F)),
  ];
}
