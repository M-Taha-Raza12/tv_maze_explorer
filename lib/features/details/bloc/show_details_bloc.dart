import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/show_repository.dart';
import 'show_details_event.dart';
import 'show_details_state.dart';

/// BLoC managing TV show details fetching, loaded state, and error handling.
class ShowDetailsBloc extends Bloc<ShowDetailsEvent, ShowDetailsState> {
  final ShowRepository showRepository;

  ShowDetailsBloc({required this.showRepository}) : super(const ShowDetailsInitial()) {
    on<ShowDetailsRequested>(_onShowDetailsRequested);
    on<ShowDetailsRetryRequested>(_onShowDetailsRetryRequested);
  }

  Future<void> _onShowDetailsRequested(
    ShowDetailsRequested event,
    Emitter<ShowDetailsState> emit,
  ) async {
    emit(const ShowDetailsLoading());
    try {
      final show = await showRepository.getShowDetails(event.showId);
      emit(ShowDetailsLoaded(show));
    } on ApiException catch (e) {
      emit(ShowDetailsError(e.message));
    } catch (e) {
      emit(ShowDetailsError('Failed to load show details: $e'));
    }
  }

  Future<void> _onShowDetailsRetryRequested(
    ShowDetailsRetryRequested event,
    Emitter<ShowDetailsState> emit,
  ) async {
    add(ShowDetailsRequested(event.showId));
  }
}
