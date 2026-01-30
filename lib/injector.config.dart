// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:tessera/features/solver/data/datasources/math_engine_service.dart'
    as _i738;
import 'package:tessera/features/solver/data/repositories/solver_repository_impl.dart'
    as _i636;
import 'package:tessera/features/solver/domain/repositories/solver_repository.dart'
    as _i108;
import 'package:tessera/features/solver/domain/services/ido_validation_service.dart'
    as _i4;
import 'package:tessera/features/solver/domain/services/latex_change_highlighter.dart'
    as _i854;
import 'package:tessera/features/solver/domain/services/step_description_mapper.dart'
    as _i672;
import 'package:tessera/features/solver/domain/usecases/solve_equation_usecase.dart'
    as _i945;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i738.MathEngineService>(() => _i738.MathEngineService());
    gh.lazySingleton<_i4.IdoValidationService>(
        () => _i4.IdoValidationService());
    gh.lazySingleton<_i854.LatexChangeHighlighter>(
        () => _i854.LatexChangeHighlighter());
    gh.lazySingleton<_i672.StepDescriptionMapper>(
        () => _i672.StepDescriptionMapper());
    gh.lazySingleton<_i108.SolverRepository>(() => _i636.SolverRepositoryImpl(
          gh<_i738.MathEngineService>(),
          gh<_i672.StepDescriptionMapper>(),
          gh<_i854.LatexChangeHighlighter>(),
          gh<_i4.IdoValidationService>(),
        ));
    gh.factory<_i945.SolveEquationUseCase>(
        () => _i945.SolveEquationUseCase(gh<_i108.SolverRepository>()));
    return this;
  }
}
