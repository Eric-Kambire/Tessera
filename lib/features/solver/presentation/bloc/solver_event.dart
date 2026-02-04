part of 'solver_bloc.dart';

abstract class SolverEvent extends Equatable {
  const SolverEvent();

  @override
  List<Object?> get props => [];
}

class SolveRequested extends SolverEvent {
  final String latexInput;
  final SolveMethod? method;

  const SolveRequested(this.latexInput, {this.method});

  @override
  List<Object?> get props => [latexInput, method];
}
