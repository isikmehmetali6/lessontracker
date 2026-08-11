// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deadline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Deadline {
  String get id;
  String get courseId;
  String get title;
  DateTime get date;
  DeadlineType get type;
  bool get reminder;

  /// Create a copy of Deadline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeadlineCopyWith<Deadline> get copyWith =>
      _$DeadlineCopyWithImpl<Deadline>(this as Deadline, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Deadline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reminder, reminder) ||
                other.reminder == reminder));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, courseId, title, date, type, reminder);

  @override
  String toString() {
    return 'Deadline(id: $id, courseId: $courseId, title: $title, date: $date, type: $type, reminder: $reminder)';
  }
}

/// @nodoc
abstract mixin class $DeadlineCopyWith<$Res> {
  factory $DeadlineCopyWith(Deadline value, $Res Function(Deadline) _then) =
      _$DeadlineCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String courseId,
      String title,
      DateTime date,
      DeadlineType type,
      bool reminder});
}

/// @nodoc
class _$DeadlineCopyWithImpl<$Res> implements $DeadlineCopyWith<$Res> {
  _$DeadlineCopyWithImpl(this._self, this._then);

  final Deadline _self;
  final $Res Function(Deadline) _then;

  /// Create a copy of Deadline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? date = null,
    Object? type = null,
    Object? reminder = null,
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
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as DeadlineType,
      reminder: null == reminder
          ? _self.reminder
          : reminder // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Deadline].
extension DeadlinePatterns on Deadline {
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
    TResult Function(_Deadline value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Deadline() when $default != null:
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
    TResult Function(_Deadline value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deadline():
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
    TResult? Function(_Deadline value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deadline() when $default != null:
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
    TResult Function(String id, String courseId, String title, DateTime date,
            DeadlineType type, bool reminder)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Deadline() when $default != null:
        return $default(_that.id, _that.courseId, _that.title, _that.date,
            _that.type, _that.reminder);
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
    TResult Function(String id, String courseId, String title, DateTime date,
            DeadlineType type, bool reminder)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deadline():
        return $default(_that.id, _that.courseId, _that.title, _that.date,
            _that.type, _that.reminder);
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
    TResult? Function(String id, String courseId, String title, DateTime date,
            DeadlineType type, bool reminder)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Deadline() when $default != null:
        return $default(_that.id, _that.courseId, _that.title, _that.date,
            _that.type, _that.reminder);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Deadline extends Deadline {
  const _Deadline(
      {required this.id,
      required this.courseId,
      required this.title,
      required this.date,
      required this.type,
      this.reminder = true})
      : super._();

  @override
  final String id;
  @override
  final String courseId;
  @override
  final String title;
  @override
  final DateTime date;
  @override
  final DeadlineType type;
  @override
  @JsonKey()
  final bool reminder;

  /// Create a copy of Deadline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeadlineCopyWith<_Deadline> get copyWith =>
      __$DeadlineCopyWithImpl<_Deadline>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Deadline &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.courseId, courseId) ||
                other.courseId == courseId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.reminder, reminder) ||
                other.reminder == reminder));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, courseId, title, date, type, reminder);

  @override
  String toString() {
    return 'Deadline(id: $id, courseId: $courseId, title: $title, date: $date, type: $type, reminder: $reminder)';
  }
}

/// @nodoc
abstract mixin class _$DeadlineCopyWith<$Res>
    implements $DeadlineCopyWith<$Res> {
  factory _$DeadlineCopyWith(_Deadline value, $Res Function(_Deadline) _then) =
      __$DeadlineCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String courseId,
      String title,
      DateTime date,
      DeadlineType type,
      bool reminder});
}

/// @nodoc
class __$DeadlineCopyWithImpl<$Res> implements _$DeadlineCopyWith<$Res> {
  __$DeadlineCopyWithImpl(this._self, this._then);

  final _Deadline _self;
  final $Res Function(_Deadline) _then;

  /// Create a copy of Deadline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? courseId = null,
    Object? title = null,
    Object? date = null,
    Object? type = null,
    Object? reminder = null,
  }) {
    return _then(_Deadline(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      courseId: null == courseId
          ? _self.courseId
          : courseId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as DeadlineType,
      reminder: null == reminder
          ? _self.reminder
          : reminder // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
