import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/show_repository.dart';
import 'cast_event.dart';
import 'cast_state.dart';

/// BLoC managing TV show cast members retrieval, states, and retry.
class CastBloc extends Bloc<CastEvent, CastState> {
  final ShowRepository showRepository;

  CastBloc({required this.showRepository}) : super(const CastInitial()) {
    on<CastRequested>(_onCastRequested);
    on<CastRetryRequested>(_onCastRetryRequested);
  }

  Future<void> _onCastRequested(
    CastRequested event,
    Emitter<CastState> emit,
  ) async {
    emit(const CastLoading());
    try {
      final cast = await showRepository.getShowCast(event.showId);
      if (cast.isEmpty) {
        emit(const CastEmpty());
      } else {
        emit(CastLoaded(cast));
      }
    } on ApiException catch (e) {
      emit(CastError(e.message));
    } catch (e) {
      emit(CastError('Failed to load cast: $e'));
    }
  }

  Future<void> _onCastRetryRequested(
    CastRetryRequested event,
    Emitter<CastState> emit,
  ) async {
    add(CastRequested(event.showId));
  }
}
