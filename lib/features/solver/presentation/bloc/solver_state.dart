part of 'solver_bloc.dart';

abstract class SolverState extends Equatable {
  const SolverState();

  @override
  List<Object?> get props => [];
}

class SolverInitial extends SolverState {
  const SolverInitial();
}

class SolverLoading extends SolverState {
  const SolverLoading();
}

class SolverLoaded extends SolverState {
  final MathSolution solution;

  const SolverLoaded(this.solution);

  @override
  List<Object?> get props => [solution];
}

class SolverError extends SolverState {
  final String message;

  const SolverError(this.message);

  @override
  List<Object?> get props => [message];
}
