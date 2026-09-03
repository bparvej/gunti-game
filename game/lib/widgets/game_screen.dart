import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/board.dart';
import '../models/guti_theme.dart';
import '../models/game_manager.dart';
import 'board_painter.dart';
import 'background_painter.dart';
import 'settings_panel.dart';
import 'stats_dialog.dart';
import 'how_to_play.dart';
import 'move_slider.dart';

class GameScreen extends StatefulWidget {
  final GameManager gameManager;

  const GameScreen({super.key, required this.gameManager});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showHowToPlay = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    widget.gameManager.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    widget.gameManager.removeListener(_onGameChanged);
    _pulseController.dispose();
    super.dispose();
  }

  void _onGameChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final gm = widget.gameManager;
    final theme = gm.currentTheme;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleBackgroundTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: _buildBackgroundGradient(gm, theme),
          ),
          child: Stack(
            children: [
              _buildBackground(gm),
              _buildBoardArea(gm, theme),
              _buildTopBar(theme, gm),
              _buildBottomBar(theme, gm),
              _buildGearButton(),
              if (gm.gameEnded && gm.winner != null)
                _buildGameOverOverlay(gm.winner!, theme),
              if (_showHowToPlay)
                HowToPlayOverlay(onDismiss: () {
                  setState(() => _showHowToPlay = false);
                }),
              if (gm.settingsOpen) SettingsPanel(gameManager: gm),
              if (gm.colorPickerOpen) _buildColorPicker(gm, theme),
              if (gm.bgSelectionOpen) _buildBackgroundPicker(gm, theme),
              if (gm.statsOpen) StatsDialog(gameManager: gm),
              if (gm.showMoveSlider)
                MoveSlider(
                  theme: theme,
                  targets: gm.moveSliderTargets,
                  selectedIndex: gm.selectedSliderIndex,
                  onIndexChanged: (i) => gm.onSliderChanged(i),
                  onConfirm: () => gm.confirmMoveFromSlider(),
                  onCancel: () => gm.cancelMoveSlider(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Gradient? _buildBackgroundGradient(GameManager gm, GutiTheme theme) {
    if (gm.customBackgroundPath != null) return null;
    if (gm.backgroundType != null) return null;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.backgroundColor,
        theme.backgroundColor.withValues(alpha: 0.8),
      ],
    );
  }

  void _handleBackgroundTap() {
    final gm = widget.gameManager;
    if (gm.settingsOpen) {
      gm.closeSettingsOverlay();
    } else if (gm.statsOpen) {
      gm.closeStats();
    } else if (gm.colorPickerOpen) {
      gm.closeColorPicker();
    } else if (gm.bgSelectionOpen) {
      gm.closeBackgroundPicker();
    } else if (gm.showMoveSlider) {
      return;
    } else {
      gm.clearSelection();
    }
  }

  Widget _buildBackground(GameManager gm) {
    final path = gm.customBackgroundPath;
    if (path != null) {
      if (path.startsWith('data:image/')) {
        final base64Data = path.split(',').last;
        final bytes = base64Decode(base64Data);
        return Positioned.fill(
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      }
      return Positioned.fill(
        child: Image.asset(path, fit: BoxFit.cover),
      );
    }

    if (gm.backgroundType != null) {
      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Center(
          child: SizedBox(
            width: Board.boardWidth,
            height: Board.boardHeight,
            child: CustomPaint(
              painter: BackgroundPainter(type: gm.backgroundType!),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBoardArea(GameManager gm, GutiTheme theme) {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: Board.boardWidth,
          height: Board.boardHeight,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(Board.boardWidth, Board.boardHeight),
                painter: BoardPainter(
                  theme: theme,
                  showHints: gm.selectedGuti != null && !gm.showMoveSlider,
                  selectedNode: gm.selectedGuti?.nodeKey,
                  hintNodes: gm.selectedGuti != null
                      ? gm.getAvailableTargets(gm.selectedGuti!)
                      : [],
                  hintColor: theme.hintColor,
                ),
              ),
              ...gm.gutis.asMap().entries.map((entry) {
                final piece = entry.value;
                final node = Board.getNode(piece.nodeKey)!;
                final isSelected = gm.isSelected(piece);
                final shape = gm.currentShape;
                final offset = _gutiOffset(shape, isSelected);

                return AnimatedPositioned(
                  left: node.x - offset.dx,
                  top: node.y - offset.dy,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  child: GestureDetector(
                    onTap: () {
                      if (gm.gameEnded || gm.settingsOpen) return;
                      if (piece.owner == gm.currentTurn) {
                        gm.selectGuti(piece);
                      }
                    },
                    child: _buildGuti(piece, gm, isSelected),
                  ),
                );
              }),
              ...Board.nodes.entries.map((entry) {
                final node = entry.value;
                return Positioned(
                  left: node.x - 24,
                  top: node.y - 24,
                  width: 48,
                  height: 48,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (gm.gameEnded ||
                          gm.settingsOpen ||
                          gm.showMoveSlider) {
                        return;
                      }
                      if (!gm.occupied.containsKey(entry.key)) {
                        if (gm.selectedGuti != null) {
                          gm.tryMove(entry.key);
                        }
                      }
                    },
                    child: const SizedBox.expand(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Offset _gutiOffset(GutiShape shape, bool isSelected) {
    final double baseSize = isSelected ? 36 : 30;
    switch (shape.id) {
      case 'square':
        return Offset(baseSize / 2, baseSize / 2);
      case 'bar':
        return Offset(baseSize * 0.2, baseSize * 0.65);
      case 'lalbadshah':
        return Offset(baseSize * 0.7, baseSize * 0.85);
      case 'circle':
      default:
        return Offset(baseSize * 0.55, baseSize * 0.55);
    }
  }

  Widget _buildGuti(GutiPiece piece, GameManager gm, bool isSelected) {
    final color = piece.color;
    final double size = isSelected ? 36 : 30;
    final shape = gm.currentShape;
    final borderColor = isSelected ? Colors.white : color.withValues(alpha: 0.3);

    final shadow = isSelected
        ? [
            BoxShadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ];

    switch (shape.id) {
      case 'square':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
            boxShadow: shadow,
          ),
        );
      case 'bar':
        return Container(
          width: size * 0.4,
          height: size * 1.3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
            boxShadow: shadow,
          ),
        );
      case 'lalbadshah':
        return SizedBox(
          width: size * 1.4,
          height: size * 1.7,
          child: CustomPaint(
            painter: _LalBadshahPainter(
              color: color,
              isSelected: isSelected,
            ),
          ),
        );
      case 'circle':
      default:
        return Container(
          width: size * 1.1,
          height: size * 1.1,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
              center: Alignment(-0.3, -0.3),
              radius: 1.2,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
            boxShadow: shadow,
          ),
        );
    }
  }

  Widget _buildTopBar(GutiTheme theme, GameManager gm) {
    final isRed = gm.currentTurn == Player.red;
    final playerColor = isRed ? theme.redColor : theme.blueColor;
    final playerName = isRed ? "RED" : "BLUE";

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        playerColor.withValues(alpha: 0.25),
                        playerColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: playerColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: playerColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: playerColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: playerColor.withValues(alpha: 0.7),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$playerName'S TURN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: playerColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(GutiTheme theme, GameManager gm) {
    String hintText;
    if (gm.gameEnded) {
      hintText = "Game Over";
    } else if (gm.selectedGuti != null) {
      final targets = gm.getAvailableTargets(gm.selectedGuti!);
      hintText = targets.isNotEmpty
          ? "${targets.length} move(s) available"
          : "No moves - select another";
    } else {
      hintText =
          "Tap a ${gm.currentTurn == Player.red ? 'RED' : 'BLUE'} guti";
    }

    final shapeIcons = {
      'circle': "●",
      'square': "■",
      'bar': "▌",
      'lalbadshah': "♛",
    };

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        shapeIcons[gm.currentShape.id] ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Shape: ${gm.currentShape.label}",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        gm.gameEnded ? Icons.emoji_events_rounded : Icons.touch_app_rounded,
                        size: 14,
                        color: gm.gameEnded
                            ? const Color(0xFFFFD700)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hintText,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGearButton() {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF50A897).withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(Icons.settings_rounded,
                color: Colors.white.withValues(alpha: 0.9), size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(Player winner, GutiTheme theme) {
    final color = winner == Player.red ? theme.redColor : theme.blueColor;
    final gm = widget.gameManager;
    final winnerName = winner == Player.red ? "RED" : "BLUE";

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 380,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      color,
                                      color.withValues(alpha: 0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "$winnerName WINS!",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: color,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: color.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.3),
                                color.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calculate_rounded,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Moves: ${gm.moveCount}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: 200,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              gm.restart();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 8,
                              shadowColor: const Color(0xFF000000).withValues(alpha: 0.3),
                            ),
                            child: const Text(
                              "PLAY AGAIN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker(GameManager gm, GutiTheme theme) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.9, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.color_lens_rounded,
                                size: 22,
                                color: const Color(0xFFC62828),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Choose Guti Colors",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            GameConfig.colorPairs[gm.colorPairIndex].name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: GameConfig.colorPairs.length,
                              itemBuilder: (context, index) {
                                final pair = GameConfig.colorPairs[index];
                                final selected = index == gm.colorPairIndex;
                                return GestureDetector(
                                  onTap: () => gm.applyColorPair(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF1A1A2E)
                                            : Colors.grey.shade200,
                                        width: selected ? 3 : 1,
                                      ),
                                      color: Colors.grey.shade50,
                                      boxShadow: selected
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.15),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: pair.p1,
                                                border:
                                                    Border.all(color: Colors.white, width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: pair.p1.withValues(alpha: 0.3),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: pair.p2,
                                                border:
                                                    Border.all(color: Colors.white, width: 2),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: pair.p2.withValues(alpha: 0.3),
                                                    blurRadius: 6,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          pair.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: selected
                                                ? const Color(0xFF1A1A2E)
                                                : Colors.grey.shade600,
                                            fontWeight: selected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPicker(GameManager gm, GutiTheme theme) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0.9, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_rounded,
                                size: 22,
                                color: const Color(0xFF00695C),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Choose Background",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: BackgroundTheme.values.length,
                              itemBuilder: (context, index) {
                                final bg = BackgroundTheme.values[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (bg.id == 'upload') {
                                      _pickBackgroundImage(context, gm);
                                    } else {
                                      gm.setDefaultBackground(bg.id);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                      color: Colors.grey.shade50,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00695C).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Icon(bg.icon,
                                              size: 24,
                                              color: const Color(0xFF00695C)),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          bg.label,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1A1A2E),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _pickBackgroundImage(BuildContext ctx, GameManager gm) async {
    final result = await gm.pickBackgroundImage();
    if (result != null) {
      gm.setCustomBackground(result);
    }
  }
}

class _LalBadshahPainter extends CustomPainter {
  final Color color;
  final bool isSelected;

  _LalBadshahPainter({required this.color, this.isSelected = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 6, 28, 36),
        const Radius.circular(4),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = (isSelected ? Colors.white : color.withValues(alpha: 0.7))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(3, 7, 26, 30),
        const Radius.circular(3),
      ),
      borderPaint,
    );

    if (isSelected) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 4, 32, 40),
          const Radius.circular(5),
        ),
        glowPaint,
      );
    }

    paint.color = Colors.white;
    canvas.save();
    canvas.translate(16, 22);
    canvas.drawCircle(Offset.zero, 3, paint);
    canvas.restore();

    paint.color = Colors.black;
    canvas.drawCircle(Offset(16, 12), 5, paint);

    paint.color = color;
    canvas.drawLine(Offset(7, 16), Offset(23, 16),
        paint..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant _LalBadshahPainter old) =>
      old.color != color || old.isSelected != isSelected;
}
