import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/stats_usecase.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsUseCase _useCase;

  StatsCubit({required StatsUseCase useCase})
      : _useCase = useCase,
        super(StatsState.initial());

  Future<void> load() async {
    final stats = await _useCase.load();
    emit(StatsState(stats: stats));
  }

  Future<void> reset() async {
    await _useCase.reset();
    emit(StatsState.initial());
  }
}