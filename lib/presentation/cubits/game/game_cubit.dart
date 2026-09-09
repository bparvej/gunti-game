import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../../domain/models/game_models.dart';
import '../../../domain/repositories/game_history_repository.dart';
import '../../../domain/repositories/game_session_repository.dart';
import '../../../domain/usecases/ai_engine.dart';
import '../../../domain/usecases/game_engine.dart';
import '../../../domain/usecases/stats_usecase.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final GameEngine _engine;
  final AiEngine _aiEngine;
  final StatsUseCase _statsUseCase;
  final AudioHelper _audio;
  final HapticsHelper _haptics;
  final GameSessionRepository _sessionRepo;
  final GameHistoryRepository _historyRepo;

  Timer? _aiTimer;

  GameCubit({
    required GameEngine engine,
    required AiEngine aiEngine,
    required StatsUseCase statsUseCase,
    required AudioHelper audio,
    required HapticsHelper haptics,
    required GameSessionRepository sessionRepository,
    required GameHistoryRepository historyRepository,
  })  : _engine = engine,
        _aiEngine = aiEngine,
        _statsUseCase = statsUseCase,
        _audio = audio,
        _haptics = haptics,
        _sessionRepo = sessionRepository,
        _historyRepo = historyRepository,
        super(GameState.initial());

  @override
  Future<void> close() {
    _aiTimer?.cancel();
    return super.close();
  }

  Future<void> loadSavedGameFlag() async {
    final snap = await _sessionRepo.load();
    if (!isClosed) {
      emit(state.copyWith(hasSavedGame: snap != null));
    }
  }

  /// Starts a fresh game with the given configuration.
  void startNewGame({
    required GameMode mode,
    required Difficulty difficulty,
    required Player humanSide,
  }) {
    _aiTimer?.cancel();
    emit(GameState.initial().copyWith(
      mode: mode,
      difficulty: difficulty,
      humanSide: humanSide,
    ));
    _sessionRepo.clear();
    if (mode == GameMode.singlePlayer && humanSide == Player.blue) {
      _scheduleAiMove();
    }
  }

  /// Resumes a previously saved (paused/abandoned) game.
  Future<void> continueGame() async {
    final snap = await _sessionRepo.load();
    if (snap == null || isClosed) return;

    _aiTimer?.cancel();
    emit(GameState(
      occupied: Map<String, String?>.from(snap.occupied),
      selectedNode: null,
      currentTurn: snap.currentTurn,
      moveCount: snap.moveCount,
      status: GameStatus.ongoing,
      moveHistory: List<MoveRecord>.from(snap.moveHistory),
      availableTargets: const [],
      mode: snap.mode,
      difficulty: snap.difficulty,
      humanSide: snap.humanSide,
      paused: false,
      aiThinking: false,
      hasSavedGame: true,
    ));

    if (snap.mode == GameMode.singlePlayer &&
        snap.currentTurn != snap.humanSide) {
      _scheduleAiMove();
    }
  }

  void pause() {
    if (state.status != GameStatus.ongoing) return;
    _aiTimer?.cancel();
    _saveSession();
    if (!isClosed) {
      emit(state.copyWith(
        paused: true,
        clearSelectedNode: true,
        availableTargets: const [],
      ));
    }
  }

  void resume() {
    if (!isClosed) {
      emit(state.copyWith(paused: false));
    }
    if (state.isAiTurn) _scheduleAiMove();
  }

  /// Restarts the current game configuration from the initial layout.
  void reset() {
    final mode = state.mode;
    final difficulty = state.difficulty;
    final humanSide = state.humanSide;
    startNewGame(mode: mode, difficulty: difficulty, humanSide: humanSide);
  }

  void onNodeTap(String nodeKey) {
    if (state.status != GameStatus.ongoing) return;
    if (state.paused) return;
    if (state.isAiTurn) return;

    final occupied = state.occupied;
    final currentTurn = state.currentTurn;
    final selected = state.selectedNode;

    // No guti selected yet — try to select
    if (selected == null) {
      final result = _engine.selectGuti(occupied, nodeKey, currentTurn, false);
      if (result != null) {
        _audio.playSelect();
        _haptics.lightTap();
        final targets = _engine.getAvailableTargets(nodeKey, occupied);
        emit(state.copyWith(
          selectedNode: nodeKey,
          availableTargets: targets,
        ));
      }
      return;
    }

    // Tapping the same guti — deselect
    if (nodeKey == selected) {
      emit(state.copyWith(
        selectedNode: null,
        clearSelectedNode: true,
        availableTargets: const [],
      ));
      return;
    }

    // Tapping another own guti — reselect
    if (occupied[nodeKey] == currentTurn.name) {
      _audio.playSelect();
      _haptics.lightTap();
      final targets = _engine.getAvailableTargets(nodeKey, occupied);
      emit(state.copyWith(
        selectedNode: nodeKey,
        availableTargets: targets,
      ));
      return;
    }

    // Try to move to target
    _attemptMove(selected, nodeKey);
  }

  void undo() {
    if (state.moveHistory.isEmpty) return;
    if (state.status != GameStatus.ongoing || state.paused) return;
    if (state.isAiTurn) return;

    // In single-player, undo grabs back the AI+human pair, restoring the
    // human's turn. In two-player, undo restores the previous player's turn.
    final count = state.mode == GameMode.singlePlayer ? 2 : 1;

    var occupied = Map<String, String?>.from(state.occupied);
    var history = List<MoveRecord>.from(state.moveHistory);
    Player? restoredTurn;

    for (var i = 0; i < count && history.isNotEmpty; i++) {
      final result = _engine.undoLast(history, occupied);
      if (result == null) break;
      final (nextOccupied, _, previousPlayer) = result;
      occupied = nextOccupied;
      history = history.sublist(0, history.length - 1);
      restoredTurn = previousPlayer;
    }

    if (restoredTurn == null) return;
    _audio.playUndo();
    _haptics.lightTap();

    emit(state.copyWith(
      occupied: occupied,
      selectedNode: null,
      clearSelectedNode: true,
      currentTurn: restoredTurn,
      moveCount: history.length,
      moveHistory: history,
      availableTargets: const [],
    ));

    _saveSession();
    if (state.isAiTurn) _scheduleAiMove();
  }

  void _attemptMove(String from, String to) {
    final currentTurn = state.currentTurn;
    final moveResult = _engine.tryMove(from, to, state.occupied);
    moveResult.fold(
      (error) {
        _audio.playError();
        _haptics.errorVibrate();
      },
      (newOccupied) {
        _applyMove(newOccupied, from, to, currentTurn);
      },
    );
  }

  void _applyMove(
    Map<String, String?> newOccupied,
    String from,
    String to,
    Player player,
  ) {
    final moveRecord = MoveRecord(
      player: player,
      from: from,
      to: to,
      moveNumber: state.moveCount + 1,
    );

    final newMoveCount = state.moveCount + 1;
    final nextTurn = player.opponent;

    // Check win after > 3 moves (mirrors the original TS rule).
    GameStatus newStatus = GameStatus.ongoing;
    Player? winner;
    if (newMoveCount > 3) {
      final result = _engine.checkWin(newOccupied);
      result.fold(
        () {},
        (w) => winner = w,
      );
      if (winner != null) {
        newStatus =
            winner == Player.red ? GameStatus.redWin : GameStatus.blueWin;
      }
    }

    final completed = newStatus != GameStatus.ongoing;

    if (completed) {
      _audio.playWin();
      _haptics.winVibrate();
      _finishGame(winner!);
    } else if (newMoveCount > 3) {
      _audio.playSlide();
      _haptics.mediumTap();
    }

    emit(state.copyWith(
      occupied: newOccupied,
      selectedNode: null,
      clearSelectedNode: true,
      currentTurn: nextTurn,
      moveCount: newMoveCount,
      status: newStatus,
      moveHistory: [...state.moveHistory, moveRecord],
      availableTargets: const [],
      aiThinking: false,
      hasSavedGame: completed ? false : state.hasSavedGame,
    ));

    if (!completed) {
      _saveSession();
      if (state.isAiTurn) _scheduleAiMove();
    }
  }

  Future<void> _finishGame(Player winner) async {
    await _statsUseCase.recordWin(winner, state.moveCount + 1);
    await _historyRepo.save(GameHistoryEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      playedAt: DateTime.now(),
      mode: state.mode,
      winner: winner,
      moveCount: state.moveCount + 1,
      difficulty: state.difficulty,
    ));
    await _sessionRepo.clear();
  }

  void _scheduleAiMove() {
    _aiTimer?.cancel();
    if (state.status != GameStatus.ongoing || state.paused || !state.isAiTurn) {
      return;
    }

    // Brief "thinking" indicator before the AI replies.
    emit(state.copyWith(
      aiThinking: true,
      clearSelectedNode: true,
      availableTargets: const [],
    ));

    final delay = switch (state.difficulty) {
      Difficulty.easy => const Duration(milliseconds: 400),
      Difficulty.medium => const Duration(milliseconds: 700),
      Difficulty.hard => const Duration(milliseconds: 1000),
    };

    _aiTimer = Timer(delay, () {
      if (isClosed) return;
      final before = state;
      if (before.status != GameStatus.ongoing ||
          before.paused ||
          !before.isAiTurn) {
        emit(before.copyWith(aiThinking: false));
        return;
      }

      final move = _aiEngine.bestMove(before.occupied, before.currentTurn,
          before.difficulty);
      move.fold(
        () {
          emit(before.copyWith(aiThinking: false));
        },
        (aiMove) {
          final moveResult =
              _engine.tryMove(aiMove.from, aiMove.to, before.occupied);
          moveResult.fold(
            (_) => emit(before.copyWith(aiThinking: false)),
            (newOccupied) {
              _applyMove(newOccupied, aiMove.from, aiMove.to, before.currentTurn);
            },
          );
        },
      );
    });
  }

  Future<void> _saveSession() async {
    final s = state;
    if (s.status != GameStatus.ongoing) return;
    await _sessionRepo.save(GameSnapshot(
      occupied: s.occupied,
      currentTurn: s.currentTurn,
      moveCount: s.moveCount,
      moveHistory: s.moveHistory,
      mode: s.mode,
      humanSide: s.humanSide,
      difficulty: s.difficulty,
    ));
    if (!isClosed && !state.hasSavedGame) {
      emit(state.copyWith(hasSavedGame: true));
    }
  }
}