part of 'solver_bloc.dart';

abstract class SolverEvent extends Equatable {
  const SolverEvent();

  @override
  List<Object?> get props => [];
}

class SolveRequested extends SolverEvent {
  final String latexInput;

  const SolveRequested(this.latexInput);

  @override
  List<Object?> get props => [latexInput];
}
