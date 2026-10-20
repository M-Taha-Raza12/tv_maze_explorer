import 'package:equatable/equatable.dart';
import '../../../domain/entities/show.dart';

abstract class ShowDetailsState extends Equatable {
  const ShowDetailsState();

  @override
  List<Object?> get props => [];
}

class ShowDetailsInitial extends ShowDetailsState {
  const ShowDetailsInitial();
}

class ShowDetailsLoading extends ShowDetailsState {
  const ShowDetailsLoading();
}

class ShowDetailsLoaded extends ShowDetailsState {
  final Show show;

  const ShowDetailsLoaded(this.show);

  @override
  List<Object?> get props => [show];
}

class ShowDetailsError extends ShowDetailsState {
  final String message;

  const ShowDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
