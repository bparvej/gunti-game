import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'board.dart';
import 'guti_theme.dart';
import '../services/audio_service.dart';
import '../services/stats_service.dart';
import '../widgets/background_painter.dart';

class GameManager extends ChangeNotifier {
  final AudioService audioService;
  final StatsService statsService;

  GameManager({required this.audioService, required this.statsService});

  final List<GutiPiece> gutis = [];
  GutiPiece? selectedGuti;
  final Map<String, GutiPiece> occupied = {};
  Player currentTurn = Player.red;
  int moveCount = 0;
  bool gameEnded = false;
  Player? winner;

  final List<MoveRecord> moveHistory = [];

  GutiShape currentShape = GutiShape.values.first;
  int colorPairIndex = 0;
  int themeIndex = 0;
  BackgroundType? backgroundType;
  String? customBackgroundPath;

  bool settingsOpen = false;
  bool statsOpen = false;
  bool colorPickerOpen = false;
  bool bgSelectionOpen = false;
  bool showMoveSlider = false;
  List<String> moveSliderTargets = [];
  int selectedSliderIndex = 0;

  GutiTheme get currentTheme => GameConfig.themes[themeIndex];
  ColorPair get currentColorPair => GameConfig.colorPairs[colorPairIndex];

  bool isSelected(GutiPiece piece) => selectedGuti == piece;

  void init() {
    gutis.clear();
    occupied.clear();
    moveHistory.clear();
    selectedGuti = null;
    currentTurn = Player.red;
    moveCount = 0;
    gameEnded = false;
    winner = null;
    settingsOpen = false;
    statsOpen = false;
    colorPickerOpen = false;
    bgSelectionOpen = false;
    showMoveSlider = false;
    moveSliderTargets = [];
    selectedSliderIndex = 0;

    for (final player in Player.values) {
      for (final pos in Board.startingPositions[player]!) {
        final piece = GutiPiece(
          nodeKey: pos,
          owner: player,
          color: player == Player.red
              ? currentColorPair.p1
              : currentColorPair.p2,
        );
        gutis.add(piece);
        occupied[pos] = piece;
      }
    }
    notifyListeners();
  }

  void switchTheme() {
    themeIndex = (themeIndex + 1) % GameConfig.themes.length;
    _updateColors();
    notifyListeners();
  }

  void switchShape() {
    final currentIndex = GutiShape.values.indexOf(currentShape);
    currentShape =
        GutiShape.values[(currentIndex + 1) % GutiShape.values.length];
    notifyListeners();
  }

  void switchColorPair() {
    colorPairIndex =
        (colorPairIndex + 1) % GameConfig.colorPairs.length;
    _updateColors();
    notifyListeners();
  }

  void _updateColors() {
    for (final piece in gutis) {
      piece.color = piece.owner == Player.red
          ? currentColorPair.p1
          : currentColorPair.p2;
    }
  }

  List<String> getAvailableTargets(GutiPiece piece) {
    return Board.getValidMoves(piece.nodeKey, occupied);
  }

  bool tryMove(String targetNode) {
    if (gameEnded || selectedGuti == null) return false;

    final from = selectedGuti!.nodeKey;
    final links = Board.getNode(from)?.links ?? [];

    if (!links.contains(targetNode)) {
      audioService.playErrorSound();
      return false;
    }

    if (occupied.containsKey(targetNode)) {
      audioService.playErrorSound();
      return false;
    }

    executeMove(from, targetNode);
    return true;
  }

  void executeMove(String from, String to) {
    final piece = occupied[from]!;
    piece.nodeKey = to;
    occupied.remove(from);
    occupied[to] = piece;

    moveHistory.add(MoveRecord(
      player: currentTurn,
      from: from,
      to: to,
      moveNumber: moveCount + 1,
    ));

    moveCount++;
    audioService.playSlideSound();

    if (moveCount > 3) {
      checkWin();
    }

    if (!gameEnded) {
      switchTurn();
    }
    notifyListeners();
  }

  void switchTurn() {
    currentTurn =
        currentTurn == Player.red ? Player.blue : Player.red;
  }

  void selectGuti(GutiPiece piece) {
    if (gameEnded) return;
    if (piece.owner != currentTurn) {
      audioService.playErrorSound();
      return;
    }
    selectedGuti = piece;
    audioService.playMoveSound();
    _showMoveSliderFor(piece);
    notifyListeners();
  }

  void clearSelection() {
    selectedGuti = null;
    _hideMoveSlider();
    notifyListeners();
  }

  void checkWin() {
    final playerPositions = <String, Player>{};
    for (final entry in occupied.entries) {
      playerPositions[entry.key] = entry.value.owner;
    }

    for (final line in Board.winningLines) {
      final owners = line.map((k) => playerPositions[k]).toSet();
      if (owners.length == 1 && owners.first != null) {
        gameOver(owners.first!);
        return;
      }
    }
  }

  void gameOver(Player winnerPlayer) {
    gameEnded = true;
    winner = winnerPlayer;
    audioService.playWinSound();
    statsService.recordWin(winnerPlayer, moveCount);
    notifyListeners();
  }

  void undoMove() {
    if (moveHistory.isEmpty) return;

    final lastMove = moveHistory.removeLast();
    final piece = occupied[lastMove.to];
    if (piece != null) {
      piece.nodeKey = lastMove.from;
      occupied.remove(lastMove.to);
      occupied[lastMove.from] = piece;
    }

    moveCount--;
    currentTurn = lastMove.player;
    selectedGuti = null;

    if (moveCount > 3 && checkWinQuiet()) {
      gameEnded = false;
      winner = null;
    }

    audioService.playMoveSound();
    notifyListeners();
  }

  bool checkWinQuiet() {
    final playerPositions = <String, Player>{};
    for (final entry in occupied.entries) {
      playerPositions[entry.key] = entry.value.owner;
    }

    for (final line in Board.winningLines) {
      final owners = line.map((k) => playerPositions[k]).toSet();
      if (owners.length == 1 && owners.first != null) {
        return true;
      }
    }
    return false;
  }

  bool canUndo() => moveHistory.isNotEmpty;

  void restart() {
    init();
  }

  void selectTile(String nodeKey) {
    if (gameEnded || settingsOpen || colorPickerOpen || bgSelectionOpen || statsOpen) return;

    final piece = occupied[nodeKey];
    if (piece != null) {
      if (piece.owner == currentTurn) {
        selectGuti(piece);
      }
    } else if (selectedGuti != null &&
        (selectedGuti!.owner == currentTurn ||
            selectedGuti == null)) {
      tryMove(nodeKey);
    }
    notifyListeners();
  }

  void _showMoveSliderFor(GutiPiece piece) {
    final targets = getAvailableTargets(piece);
    moveSliderTargets = targets;
    showMoveSlider = targets.isNotEmpty;
    selectedSliderIndex = 0;
    if (showMoveSlider) {
      clearHintsInSlider();
    }
    notifyListeners();
  }

  void hideMoveSlider() {
    showMoveSlider = false;
    moveSliderTargets = [];
    selectedSliderIndex = 0;
    notifyListeners();
  }

  void _hideMoveSlider() {
    showMoveSlider = false;
    moveSliderTargets = [];
  }

  void clearHintsInSlider() {}

  void onSliderChanged(int index) {
    selectedSliderIndex = index;
    notifyListeners();
  }

  void confirmMoveFromSlider() {
    if (selectedGuti == null ||
        moveSliderTargets.isEmpty ||
        selectedSliderIndex >= moveSliderTargets.length) {
      hideMoveSlider();
      return;
    }
    final target = moveSliderTargets[selectedSliderIndex];
    hideMoveSlider();
    tryMove(target);
  }

  void cancelMoveSlider() {
    hideMoveSlider();
    if (selectedGuti != null) {
      selectedGuti = null;
    }
    notifyListeners();
  }

  void openSettings() {
    settingsOpen = true;
    notifyListeners();
  }

  void closeSettingsOverlay() {
    settingsOpen = false;
    colorPickerOpen = false;
    bgSelectionOpen = false;
    notifyListeners();
  }

  void openColorPicker() {
    colorPickerOpen = true;
    notifyListeners();
  }

  void closeColorPicker() {
    colorPickerOpen = false;
    notifyListeners();
  }

  void applyColorPair(int index) {
    colorPairIndex = index;
    _updateColors();
    colorPickerOpen = false;
    notifyListeners();
  }

  void openBackgroundPicker() {
    bgSelectionOpen = true;
    notifyListeners();
  }

  void closeBackgroundPicker() {
    bgSelectionOpen = false;
    notifyListeners();
  }

  void setDefaultBackground(String bgId) {
    backgroundType = BackgroundType.values.firstWhere(
      (t) => t.name == bgId,
      orElse: () => BackgroundType.teakwood,
    );
    customBackgroundPath = null;
    bgSelectionOpen = false;
    notifyListeners();
  }

  void setCustomBackground(String path) {
    customBackgroundPath = path;
    bgSelectionOpen = false;
    notifyListeners();
  }

  Future<String?> pickBackgroundImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final base64 = base64Encode(bytes);
        return 'data:image/${result.files.single.extension};base64,$base64';
      }
    } catch (_) {}
    return null;
  }

  void showStats() {
    closeSettingsOverlay();
    statsOpen = true;
    notifyListeners();
  }

  void closeStats() {
    statsOpen = false;
    notifyListeners();
  }
}
