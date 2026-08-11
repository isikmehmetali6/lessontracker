// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grade.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Grade {
  String get id;
  String get courseId;
  String get name; // e.g. "Midterm", "Final"
  double get score; // e.g. 85.0
  double get maxScore; // e.g. 100.0
  double get weight; // e.g. 30.0 (percent)
  DateTime get createdAt;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GradeCopyWith<Grade> get copyWith =>
      _$GradeCopyWithImpl<Grade>(this as Grade, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Grade &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, courseId, name, score, maxScore, weight, createdAt);

  @override
  String toString() {
    return 'Grade(id: $id, courseId: $courseId, name: $name, score: $score, maxScore: $maxScore, weight: $weight, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $GradeCopyWith<$Res> {
  factory $GradeCopyWith(Grade value, $Res Function(Grade) _then) =
      _$GradeCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String courseId,
      String name,
      double score,
      double maxScore,
      double weight,
      DateTime createdAt});
}

/// @nodoc
class _$GradeCopyWithImpl<$Res> implements $GradeCopyWith<$Res> {
  _$GradeCopyWithImpl(this._self, this._then);

  final Grade _self;
  final $Res Function(Grade) _then;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? name = null,
    Object? score = null,
    Object? maxScore = null,
    Object? weight = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _self.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      maxScore: null == maxScore
          ? _self.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [Grade].
extension GradePatterns on Grade {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Grade value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Grade() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Grade value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Grade():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Grade value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Grade() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(String id, String courseId, String name, double score,
            double maxScore, double weight, DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Grade() when $default != null:
        return $default(_that.id, _that.courseId, _that.name, _that.score,
            _that.maxScore, _that.weight, _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String id, String courseId, String name, double score,
            double maxScore, double weight, DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Grade():
        return $default(_that.id, _that.courseId, _that.name, _that.score,
            _that.maxScore, _that.weight, _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(String id, String courseId, String name, double score,
            double maxScore, double weight, DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Grade() when $default != null:
        return $default(_that.id, _that.courseId, _that.name, _that.score,
            _that.maxScore, _that.weight, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Grade extends Grade {
  const _Grade(
      {required this.id,
      required this.courseId,
      required this.name,
      required this.score,
      this.maxScore = 100.0,
      required this.weight,
      required this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String courseId;
  @override
  final String name;
// e.g. "Midterm", "Final"
  @override
  final double score;
// e.g. 85.0
  @override
  @JsonKey()
  final double maxScore;
// e.g. 100.0
  @override
  final double weight;
// e.g. 30.0 (percent)
  @override
  final DateTime createdAt;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GradeCopyWith<_Grade> get copyWith =>
      __$GradeCopyWithImpl<_Grade>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Grade &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.maxScore, maxScore) ||
                other.maxScore == maxScore) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, courseId, name, score, maxScore, weight, createdAt);

  @override
  String toString() {
    return 'Grade(id: $id, courseId: $courseId, name: $name, score: $score, maxScore: $maxScore, weight: $weight, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$GradeCopyWith<$Res> implements $GradeCopyWith<$Res> {
  factory _$GradeCopyWith(_Grade value, $Res Function(_Grade) _then) =
      __$GradeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String courseId,
      String name,
      double score,
      double maxScore,
      double weight,
      DateTime createdAt});
}

/// @nodoc
class __$GradeCopyWithImpl<$Res> implements _$GradeCopyWith<$Res> {
  __$GradeCopyWithImpl(this._self, this._then);

  final _Grade _self;
  final $Res Function(_Grade) _then;

  /// Create a copy of Grade
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? name = null,
    Object? score = null,
    Object? maxScore = null,
    Object? weight = null,
    Object? createdAt = null,
  }) {
    return _then(_Grade(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _self.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      maxScore: null == maxScore
          ? _self.maxScore
          : maxScore // ignore: cast_nullable_to_non_nullable
              as double,
      weight: null == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
