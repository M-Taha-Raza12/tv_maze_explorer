import 'package:equatable/equatable.dart';

abstract class CastEvent extends Equatable {
  const CastEvent();

  @override
  List<Object?> get props => [];
}

class CastRequested extends CastEvent {
  final int showId;

  const CastRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}

class CastRetryRequested extends CastEvent {
  final int showId;

  const CastRetryRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}
