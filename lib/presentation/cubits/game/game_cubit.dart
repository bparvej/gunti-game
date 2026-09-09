import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/utils/haptics_helper.dart';
import '../../../domain/models/game_models.dart';
import '../../../domain/usecases/game_engine.dart';
import '../../../domain/usecases/stats_usecase.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final GameEngine _engine;
  final StatsUseCase _statsUseCase;
  final AudioHelper _audio;
  final HapticsHelper _haptics;

  GameCubit({
    required GameEngine engine,
    required StatsUseCase statsUseCase,
    required AudioHelper audio,
    required HapticsHelper haptics,
  })  : _engine = engine,
        _statsUseCase = statsUseCase,
        _audio = audio,
        _haptics = haptics,
        super(GameState.initial());

  void onNodeTap(String nodeKey) {
    if (state.status != GameStatus.ongoing) return;

    final occupied = state.occupied;
    final currentTurn = state.currentTurn;
    final selected = state.selectedNode;

    // If no guti selected yet — try to select
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

    // If tapping the same guti — deselect
    if (nodeKey == selected) {
      emit(state.copyWith(
        selectedNode: null,
        availableTargets: [],
      ));
      return;
    }

    // If tapping another own guti — reselect
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
    final moveResult = _engine.tryMove(selected, nodeKey, occupied);
    moveResult.fold(
      (error) {
        _audio.playError();
        _haptics.errorVibrate();
      },
      (newOccupied) {
        final moveRecord = MoveRecord(
          player: currentTurn,
          from: selected,
          to: nodeKey,
          moveNumber: state.moveCount + 1,
        );

        final newMoveCount = state.moveCount + 1;
        final nextTurn = currentTurn == Player.red ? Player.blue : Player.red;

        // Check win after > 3 moves
        GameStatus newStatus = GameStatus.ongoing;
        if (newMoveCount > 3) {
          final winner = _engine.checkWin(newOccupied);
          winner.fold(
            () {},
            (w) {
              newStatus = w == Player.red ? GameStatus.redWin : GameStatus.blueWin;
              _audio.playWin();
              _haptics.winVibrate();
              _statsUseCase.recordWin(w, newMoveCount);
            },
          );
        }

        if (newStatus == GameStatus.ongoing) {
          _audio.playSlide();
          _haptics.mediumTap();
        }

        emit(state.copyWith(
          occupied: newOccupied,
          selectedNode: null,
          currentTurn: nextTurn,
          moveCount: newMoveCount,
          status: newStatus,
          moveHistory: [...state.moveHistory, moveRecord],
          availableTargets: [],
        ));
      },
    );
  }

  void undo() {
    if (state.moveHistory.isEmpty || state.status != GameStatus.ongoing) return;

    final result = _engine.undoLast(state.moveHistory, state.occupied);
    if (result == null) return;

    final (newOccupied, undoneMove, previousPlayer) = result;
    _audio.playUndo();
    _haptics.lightTap();

    emit(state.copyWith(
      occupied: newOccupied,
      selectedNode: null,
      currentTurn: previousPlayer,
      moveCount: state.moveCount - 1,
      moveHistory: state.moveHistory.sublist(0, state.moveHistory.length - 1),
      availableTargets: [],
    ));
  }

  void newGame() {
    emit(GameState.initial());
    _audio.playFunny();
  }
}