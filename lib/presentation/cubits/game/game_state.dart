import 'package:equatable/equatable.dart';
import '../../../domain/models/game_models.dart';

class GameState extends Equatable {
  final Map<String, String?> occupied;
  final String? selectedNode;
  final Player currentTurn;
  final int moveCount;
  final GameStatus status;
  final List<MoveRecord> moveHistory;
  final List<String> availableTargets;
  final GameMode mode;
  final Difficulty difficulty;
  final Player humanSide;
  final bool paused;
  final bool aiThinking;
  final bool hasSavedGame;

  const GameState({
    required this.occupied,
    required this.selectedNode,
    required this.currentTurn,
    required this.moveCount,
    required this.status,
    required this.moveHistory,
    required this.availableTargets,
    required this.mode,
    required this.difficulty,
    required this.humanSide,
    required this.paused,
    required this.aiThinking,
    required this.hasSavedGame,
  });

  factory GameState.initial() => GameState(
        occupied: initialOccupiedMap(),
        selectedNode: null,
        currentTurn: Player.red,
        moveCount: 0,
        status: GameStatus.ongoing,
        moveHistory: const [],
        availableTargets: const [],
        mode: GameMode.twoPlayers,
        difficulty: Difficulty.medium,
        humanSide: Player.red,
        paused: false,
        aiThinking: false,
        hasSavedGame: false,
      );

  /// True when the device must move next in single-player mode.
  bool get isAiTurn =>
      mode == GameMode.singlePlayer &&
      status == GameStatus.ongoing &&
      !paused &&
      !aiThinking &&
      currentTurn != humanSide;

  GameState copyWith({
    Map<String, String?>? occupied,
    String? selectedNode,
    bool clearSelectedNode = false,
    Player? currentTurn,
    int? moveCount,
    GameStatus? status,
    List<MoveRecord>? moveHistory,
    List<String>? availableTargets,
    GameMode? mode,
    Difficulty? difficulty,
    Player? humanSide,
    bool? paused,
    bool? aiThinking,
    bool? hasSavedGame,
  }) {
    return GameState(
      occupied: occupied ?? this.occupied,
      selectedNode: clearSelectedNode ? null : selectedNode,
      currentTurn: currentTurn ?? this.currentTurn,
      moveCount: moveCount ?? this.moveCount,
      status: status ?? this.status,
      moveHistory: moveHistory ?? this.moveHistory,
      availableTargets: availableTargets ?? this.availableTargets,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      humanSide: humanSide ?? this.humanSide,
      paused: paused ?? this.paused,
      aiThinking: aiThinking ?? this.aiThinking,
      hasSavedGame: hasSavedGame ?? this.hasSavedGame,
    );
  }

  @override
  List<Object?> get props => [
        occupied, selectedNode, currentTurn, moveCount,
        status, moveHistory, availableTargets, mode,
        difficulty, humanSide, paused, aiThinking, hasSavedGame,
      ];
}