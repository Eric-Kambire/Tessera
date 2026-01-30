import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/math_solution.dart';
import '../../domain/usecases/solve_equation_usecase.dart';
import '../../../../core/errors/failures.dart';

part 'solver_event.dart';
part 'solver_state.dart';

@injectable
class SolverBloc extends Bloc<SolverEvent, SolverState> {
  final SolveEquationUseCase solveEquation;

  SolverBloc(this.solveEquation) : super(const SolverInitial()) {
    on<SolveRequested>(_onSolveRequested);
  }

  Future<void> _onSolveRequested(
    SolveRequested event,
    Emitter<SolverState> emit,
  ) async {
    emit(const SolverLoading());
    try {
      final solution = await solveEquation(SolveEquationParams(event.latexInput));
      emit(SolverLoaded(solution));
    } catch (e) {
      if (e is Failure) {
        emit(SolverError(e.message));
      } else {
        emit(SolverError(e.toString()));
      }
    }
  }
}
