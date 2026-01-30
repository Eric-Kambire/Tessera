// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'math_solution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MathSolution {
  String get problemLatex => throw _privateConstructorUsedError;
  List<SolutionStep> get steps => throw _privateConstructorUsedError;
  String get finalAnswerLatex => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MathSolutionCopyWith<MathSolution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MathSolutionCopyWith<$Res> {
  factory $MathSolutionCopyWith(
          MathSolution value, $Res Function(MathSolution) then) =
      _$MathSolutionCopyWithImpl<$Res, MathSolution>;
  @useResult
  $Res call(
      {String problemLatex, List<SolutionStep> steps, String finalAnswerLatex});
}

/// @nodoc
class _$MathSolutionCopyWithImpl<$Res, $Val extends MathSolution>
    implements $MathSolutionCopyWith<$Res> {
  _$MathSolutionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemLatex = null,
    Object? steps = null,
    Object? finalAnswerLatex = null,
  }) {
    return _then(_value.copyWith(
      problemLatex: null == problemLatex
          ? _value.problemLatex
          : problemLatex // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<SolutionStep>,
      finalAnswerLatex: null == finalAnswerLatex
          ? _value.finalAnswerLatex
          : finalAnswerLatex // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MathSolutionImplCopyWith<$Res>
    implements $MathSolutionCopyWith<$Res> {
  factory _$$MathSolutionImplCopyWith(
          _$MathSolutionImpl value, $Res Function(_$MathSolutionImpl) then) =
      __$$MathSolutionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String problemLatex, List<SolutionStep> steps, String finalAnswerLatex});
}

/// @nodoc
class __$$MathSolutionImplCopyWithImpl<$Res>
    extends _$MathSolutionCopyWithImpl<$Res, _$MathSolutionImpl>
    implements _$$MathSolutionImplCopyWith<$Res> {
  __$$MathSolutionImplCopyWithImpl(
      _$MathSolutionImpl _value, $Res Function(_$MathSolutionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? problemLatex = null,
    Object? steps = null,
    Object? finalAnswerLatex = null,
  }) {
    return _then(_$MathSolutionImpl(
      problemLatex: null == problemLatex
          ? _value.problemLatex
          : problemLatex // ignore: cast_nullable_to_non_nullable
              as String,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<SolutionStep>,
      finalAnswerLatex: null == finalAnswerLatex
          ? _value.finalAnswerLatex
          : finalAnswerLatex // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$MathSolutionImpl implements _MathSolution {
  const _$MathSolutionImpl(
      {required this.problemLatex,
      required final List<SolutionStep> steps,
      required this.finalAnswerLatex})
      : _steps = steps;

  @override
  final String problemLatex;
  final List<SolutionStep> _steps;
  @override
  List<SolutionStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final String finalAnswerLatex;

  @override
  String toString() {
    return 'MathSolution(problemLatex: $problemLatex, steps: $steps, finalAnswerLatex: $finalAnswerLatex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MathSolutionImpl &&
            (identical(other.problemLatex, problemLatex) ||
                other.problemLatex == problemLatex) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.finalAnswerLatex, finalAnswerLatex) ||
                other.finalAnswerLatex == finalAnswerLatex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, problemLatex,
      const DeepCollectionEquality().hash(_steps), finalAnswerLatex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MathSolutionImplCopyWith<_$MathSolutionImpl> get copyWith =>
      __$$MathSolutionImplCopyWithImpl<_$MathSolutionImpl>(this, _$identity);
}

abstract class _MathSolution implements MathSolution {
  const factory _MathSolution(
      {required final String problemLatex,
      required final List<SolutionStep> steps,
      required final String finalAnswerLatex}) = _$MathSolutionImpl;

  @override
  String get problemLatex;
  @override
  List<SolutionStep> get steps;
  @override
  String get finalAnswerLatex;
  @override
  @JsonKey(ignore: true)
  _$$MathSolutionImplCopyWith<_$MathSolutionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
