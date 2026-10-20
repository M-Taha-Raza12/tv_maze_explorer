import 'package:equatable/equatable.dart';
import '../../../domain/entities/cast_member.dart';

abstract class CastState extends Equatable {
  const CastState();

  @override
  List<Object?> get props => [];
}

class CastInitial extends CastState {
  const CastInitial();
}

class CastLoading extends CastState {
  const CastLoading();
}

class CastLoaded extends CastState {
  final List<CastMember> cast;

  const CastLoaded(this.cast);

  @override
  List<Object?> get props => [cast];
}

class CastEmpty extends CastState {
  const CastEmpty();
}

class CastError extends CastState {
  final String message;

  const CastError(this.message);

  @override
  List<Object?> get props => [message];
}
