import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injector.config.dart';
import 'features/solver/data/datasources/math_engine_service.dart';
import 'features/solver/data/repositories/solver_repository_impl.dart';
import 'features/solver/domain/repositories/solver_repository.dart';
import 'features/solver/domain/services/ido_validation_service.dart';
import 'features/solver/domain/services/latex_change_highlighter.dart';
import 'features/solver/domain/services/step_description_mapper.dart';
import 'features/solver/domain/usecases/solve_equation_usecase.dart';
import 'features/solver/presentation/bloc/solver_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  if (!getIt.isRegistered<MathEngineService>()) {
    getIt.registerLazySingleton<MathEngineService>(MathEngineService.new);
  }
  if (!getIt.isRegistered<StepDescriptionMapper>()) {
    getIt.registerLazySingleton<StepDescriptionMapper>(StepDescriptionMapper.new);
  }
  if (!getIt.isRegistered<LatexChangeHighlighter>()) {
    getIt.registerLazySingleton<LatexChangeHighlighter>(LatexChangeHighlighter.new);
  }
  if (!getIt.isRegistered<IdoValidationService>()) {
    getIt.registerLazySingleton<IdoValidationService>(IdoValidationService.new);
  }
  if (!getIt.isRegistered<SolverRepository>()) {
    getIt.registerLazySingleton<SolverRepository>(
      () => SolverRepositoryImpl(
        getIt<MathEngineService>(),
        getIt<StepDescriptionMapper>(),
        getIt<LatexChangeHighlighter>(),
        getIt<IdoValidationService>(),
      ),
    );
  }
  if (!getIt.isRegistered<SolveEquationUseCase>()) {
    getIt.registerFactory(() => SolveEquationUseCase(getIt<SolverRepository>()));
  }
  if (!getIt.isRegistered<SolverBloc>()) {
    getIt.registerFactory(() => SolverBloc(getIt<SolveEquationUseCase>()));
  }
}
