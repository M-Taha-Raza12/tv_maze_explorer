import 'package:equatable/equatable.dart';

abstract class ShowDetailsEvent extends Equatable {
  const ShowDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ShowDetailsRequested extends ShowDetailsEvent {
  final int showId;

  const ShowDetailsRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}

class ShowDetailsRetryRequested extends ShowDetailsEvent {
  final int showId;

  const ShowDetailsRetryRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}
