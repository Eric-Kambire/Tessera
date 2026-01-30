// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'solution_step.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SolutionStep {
  String get inputLatex => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get outputLatex => throw _privateConstructorUsedError;
  bool get isSubstep => throw _privateConstructorUsedError;
  List<SolutionStep> get subSteps => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SolutionStepCopyWith<SolutionStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SolutionStepCopyWith<$Res> {
  factory $SolutionStepCopyWith(
          SolutionStep value, $Res Function(SolutionStep) then) =
      _$SolutionStepCopyWithImpl<$Res, SolutionStep>;
  @useResult
  $Res call(
      {String inputLatex,
      String description,
      String outputLatex,
      bool isSubstep,
      List<SolutionStep> subSteps});
}

/// @nodoc
class _$SolutionStepCopyWithImpl<$Res, $Val extends SolutionStep>
    implements $SolutionStepCopyWith<$Res> {
  _$SolutionStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputLatex = null,
    Object? description = null,
    Object? outputLatex = null,
    Object? isSubstep = null,
    Object? subSteps = null,
  }) {
    return _then(_value.copyWith(
      inputLatex: null == inputLatex
          ? _value.inputLatex
          : inputLatex // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      outputLatex: null == outputLatex
          ? _value.outputLatex
          : outputLatex // ignore: cast_nullable_to_non_nullable
              as String,
      isSubstep: null == isSubstep
          ? _value.isSubstep
          : isSubstep // ignore: cast_nullable_to_non_nullable
              as bool,
      subSteps: null == subSteps
          ? _value.subSteps
          : subSteps // ignore: cast_nullable_to_non_nullable
              as List<SolutionStep>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SolutionStepImplCopyWith<$Res>
    implements $SolutionStepCopyWith<$Res> {
  factory _$$SolutionStepImplCopyWith(
          _$SolutionStepImpl value, $Res Function(_$SolutionStepImpl) then) =
      __$$SolutionStepImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inputLatex,
      String description,
      String outputLatex,
      bool isSubstep,
      List<SolutionStep> subSteps});
}

/// @nodoc
class __$$SolutionStepImplCopyWithImpl<$Res>
    extends _$SolutionStepCopyWithImpl<$Res, _$SolutionStepImpl>
    implements _$$SolutionStepImplCopyWith<$Res> {
  __$$SolutionStepImplCopyWithImpl(
      _$SolutionStepImpl _value, $Res Function(_$SolutionStepImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inputLatex = null,
    Object? description = null,
    Object? outputLatex = null,
    Object? isSubstep = null,
    Object? subSteps = null,
  }) {
    return _then(_$SolutionStepImpl(
      inputLatex: null == inputLatex
          ? _value.inputLatex
          : inputLatex // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      outputLatex: null == outputLatex
          ? _value.outputLatex
          : outputLatex // ignore: cast_nullable_to_non_nullable
              as String,
      isSubstep: null == isSubstep
          ? _value.isSubstep
          : isSubstep // ignore: cast_nullable_to_non_nullable
              as bool,
      subSteps: null == subSteps
          ? _value._subSteps
          : subSteps // ignore: cast_nullable_to_non_nullable
              as List<SolutionStep>,
    ));
  }
}

/// @nodoc

class _$SolutionStepImpl implements _SolutionStep {
  const _$SolutionStepImpl(
      {required this.inputLatex,
      required this.description,
      required this.outputLatex,
      this.isSubstep = false,
      final List<SolutionStep> subSteps = const <SolutionStep>[]})
      : _subSteps = subSteps;

  @override
  final String inputLatex;
  @override
  final String description;
  @override
  final String outputLatex;
  @override
  @JsonKey()
  final bool isSubstep;
  final List<SolutionStep> _subSteps;
  @override
  @JsonKey()
  List<SolutionStep> get subSteps {
    if (_subSteps is EqualUnmodifiableListView) return _subSteps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_subSteps);
  }

  @override
  String toString() {
    return 'SolutionStep(inputLatex: $inputLatex, description: $description, outputLatex: $outputLatex, isSubstep: $isSubstep, subSteps: $subSteps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SolutionStepImpl &&
            (identical(other.inputLatex, inputLatex) ||
                other.inputLatex == inputLatex) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.outputLatex, outputLatex) ||
                other.outputLatex == outputLatex) &&
            (identical(other.isSubstep, isSubstep) ||
                other.isSubstep == isSubstep) &&
            const DeepCollectionEquality().equals(other._subSteps, _subSteps));
  }

  @override
  int get hashCode => Object.hash(runtimeType, inputLatex, description,
      outputLatex, isSubstep, const DeepCollectionEquality().hash(_subSteps));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SolutionStepImplCopyWith<_$SolutionStepImpl> get copyWith =>
      __$$SolutionStepImplCopyWithImpl<_$SolutionStepImpl>(this, _$identity);
}

abstract class _SolutionStep implements SolutionStep {
  const factory _SolutionStep(
      {required final String inputLatex,
      required final String description,
      required final String outputLatex,
      final bool isSubstep,
      final List<SolutionStep> subSteps}) = _$SolutionStepImpl;

  @override
  String get inputLatex;
  @override
  String get description;
  @override
  String get outputLatex;
  @override
  bool get isSubstep;
  @override
  List<SolutionStep> get subSteps;
  @override
  @JsonKey(ignore: true)
  _$$SolutionStepImplCopyWith<_$SolutionStepImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
