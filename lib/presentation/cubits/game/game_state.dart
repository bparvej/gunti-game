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

  const GameState({
    required this.occupied,
    required this.selectedNode,
    required this.currentTurn,
    required this.moveCount,
    required this.status,
    required this.moveHistory,
    required this.availableTargets,
  });

  factory GameState.initial() {
    return GameState(
      occupied: {
        'T': 'red', 'TL': 'red', 'TR': 'red',
        'B': 'blue', 'BL': 'blue', 'BR': 'blue',
        'C': null, 'L': null, 'R': null,
      },
      selectedNode: null,
      currentTurn: Player.red,
      moveCount: 0,
      status: GameStatus.ongoing,
      moveHistory: const [],
      availableTargets: const [],
    );
  }

  GameState copyWith({
    Map<String, String?>? occupied,
    String? selectedNode,
    bool clearSelectedNode = false,
    Player? currentTurn,
    int? moveCount,
    GameStatus? status,
    List<MoveRecord>? moveHistory,
    List<String>? availableTargets,
  }) {
    return GameState(
      occupied: occupied ?? this.occupied,
      selectedNode: clearSelectedNode ? null : selectedNode,
      currentTurn: currentTurn ?? this.currentTurn,
      moveCount: moveCount ?? this.moveCount,
      status: status ?? this.status,
      moveHistory: moveHistory ?? this.moveHistory,
      availableTargets: availableTargets ?? this.availableTargets,
    );
  }

  @override
  List<Object?> get props => [
        occupied, selectedNode, currentTurn, moveCount,
        status, moveHistory, availableTargets,
      ];
}