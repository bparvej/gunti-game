import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/game_models.dart';
import '../../../domain/repositories/game_history_repository.dart';

class HistoryState extends Equatable {
  final List<GameHistoryEntry> entries;
  final bool loaded;

  const HistoryState({required this.entries, this.loaded = false});

  const HistoryState.initial()
      : entries = const [],
        loaded = false;

  HistoryState copyWith({List<GameHistoryEntry>? entries, bool? loaded}) =>
      HistoryState(entries: entries ?? this.entries, loaded: loaded ?? this.loaded);

  @override
  List<Object?> get props => [entries, loaded];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required GameHistoryRepository repository})
      : _repo = repository,
        super(const HistoryState.initial());

  final GameHistoryRepository _repo;

  Future<void> load() async {
    final entries = await _repo.load();
    final sorted = [...entries]..sort((a, b) => b.playedAt.compareTo(a.playedAt));
    if (!isClosed) emit(HistoryState(entries: sorted, loaded: true));
  }

  Future<void> clear() async {
    await _repo.clear();
    if (!isClosed) emit(const HistoryState(entries: [], loaded: true));
  }
}