// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Course {

 String get id; String get name; String? get subtitle; String? get professor; String? get location; Color get color; List<int> get scheduleDays;// 0 = Pazartesi, 6 = Pazar
 TimeOfDay get startTime; TimeOfDay get endTime; int get absenceLimit; int get currentAbsences; double get progress; String? get iconName; DateTime? get createdAt; DateTime? get nextExamDate; int get credits; String get status;// 'active', 'completed', 'archived'
 List<DateTime> get absenceDates; double? get latitude; double? get longitude;
/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CourseCopyWith<Course> get copyWith => _$CourseCopyWithImpl<Course>(this as Course, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Course&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.professor, professor) || other.professor == professor)&&(identical(other.location, location) || other.location == location)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other.scheduleDays, scheduleDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.absenceLimit, absenceLimit) || other.absenceLimit == absenceLimit)&&(identical(other.currentAbsences, currentAbsences) || other.currentAbsences == currentAbsences)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.nextExamDate, nextExamDate) || other.nextExamDate == nextExamDate)&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.absenceDates, absenceDates)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,subtitle,professor,location,color,const DeepCollectionEquality().hash(scheduleDays),startTime,endTime,absenceLimit,currentAbsences,progress,iconName,createdAt,nextExamDate,credits,status,const DeepCollectionEquality().hash(absenceDates),latitude,longitude]);

@override
String toString() {
  return 'Course(id: $id, name: $name, subtitle: $subtitle, professor: $professor, location: $location, color: $color, scheduleDays: $scheduleDays, startTime: $startTime, endTime: $endTime, absenceLimit: $absenceLimit, currentAbsences: $currentAbsences, progress: $progress, iconName: $iconName, createdAt: $createdAt, nextExamDate: $nextExamDate, credits: $credits, status: $status, absenceDates: $absenceDates, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $CourseCopyWith<$Res>  {
  factory $CourseCopyWith(Course value, $Res Function(Course) _then) = _$CourseCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? subtitle, String? professor, String? location, Color color, List<int> scheduleDays, TimeOfDay startTime, TimeOfDay endTime, int absenceLimit, int currentAbsences, double progress, String? iconName, DateTime? createdAt, DateTime? nextExamDate, int credits, String status, List<DateTime> absenceDates, double? latitude, double? longitude
});




}
/// @nodoc
class _$CourseCopyWithImpl<$Res>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._self, this._then);

  final Course _self;
  final $Res Function(Course) _then;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? subtitle = freezed,Object? professor = freezed,Object? location = freezed,Object? color = null,Object? scheduleDays = null,Object? startTime = null,Object? endTime = null,Object? absenceLimit = null,Object? currentAbsences = null,Object? progress = null,Object? iconName = freezed,Object? createdAt = freezed,Object? nextExamDate = freezed,Object? credits = null,Object? status = null,Object? absenceDates = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,professor: freezed == professor ? _self.professor : professor // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,scheduleDays: null == scheduleDays ? _self.scheduleDays : scheduleDays // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,absenceLimit: null == absenceLimit ? _self.absenceLimit : absenceLimit // ignore: cast_nullable_to_non_nullable
as int,currentAbsences: null == currentAbsences ? _self.currentAbsences : currentAbsences // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextExamDate: freezed == nextExamDate ? _self.nextExamDate : nextExamDate // ignore: cast_nullable_to_non_nullable
as DateTime?,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,absenceDates: null == absenceDates ? _self.absenceDates : absenceDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Course].
extension CoursePatterns on Course {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Course value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Course value)  $default,){
final _that = this;
switch (_that) {
case _Course():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Course value)?  $default,){
final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? subtitle,  String? professor,  String? location,  Color color,  List<int> scheduleDays,  TimeOfDay startTime,  TimeOfDay endTime,  int absenceLimit,  int currentAbsences,  double progress,  String? iconName,  DateTime? createdAt,  DateTime? nextExamDate,  int credits,  String status,  List<DateTime> absenceDates,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that.id,_that.name,_that.subtitle,_that.professor,_that.location,_that.color,_that.scheduleDays,_that.startTime,_that.endTime,_that.absenceLimit,_that.currentAbsences,_that.progress,_that.iconName,_that.createdAt,_that.nextExamDate,_that.credits,_that.status,_that.absenceDates,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? subtitle,  String? professor,  String? location,  Color color,  List<int> scheduleDays,  TimeOfDay startTime,  TimeOfDay endTime,  int absenceLimit,  int currentAbsences,  double progress,  String? iconName,  DateTime? createdAt,  DateTime? nextExamDate,  int credits,  String status,  List<DateTime> absenceDates,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _Course():
return $default(_that.id,_that.name,_that.subtitle,_that.professor,_that.location,_that.color,_that.scheduleDays,_that.startTime,_that.endTime,_that.absenceLimit,_that.currentAbsences,_that.progress,_that.iconName,_that.createdAt,_that.nextExamDate,_that.credits,_that.status,_that.absenceDates,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? subtitle,  String? professor,  String? location,  Color color,  List<int> scheduleDays,  TimeOfDay startTime,  TimeOfDay endTime,  int absenceLimit,  int currentAbsences,  double progress,  String? iconName,  DateTime? createdAt,  DateTime? nextExamDate,  int credits,  String status,  List<DateTime> absenceDates,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _Course() when $default != null:
return $default(_that.id,_that.name,_that.subtitle,_that.professor,_that.location,_that.color,_that.scheduleDays,_that.startTime,_that.endTime,_that.absenceLimit,_that.currentAbsences,_that.progress,_that.iconName,_that.createdAt,_that.nextExamDate,_that.credits,_that.status,_that.absenceDates,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc


class _Course extends Course {
  const _Course({required this.id, required this.name, this.subtitle, this.professor, this.location, required this.color, required final  List<int> scheduleDays, required this.startTime, required this.endTime, this.absenceLimit = 3, this.currentAbsences = 0, this.progress = 0.0, this.iconName, this.createdAt, this.nextExamDate, this.credits = 3, this.status = 'active', final  List<DateTime> absenceDates = const [], this.latitude, this.longitude}): _scheduleDays = scheduleDays,_absenceDates = absenceDates,super._();
  

@override final  String id;
@override final  String name;
@override final  String? subtitle;
@override final  String? professor;
@override final  String? location;
@override final  Color color;
 final  List<int> _scheduleDays;
@override List<int> get scheduleDays {
  if (_scheduleDays is EqualUnmodifiableListView) return _scheduleDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduleDays);
}

// 0 = Pazartesi, 6 = Pazar
@override final  TimeOfDay startTime;
@override final  TimeOfDay endTime;
@override@JsonKey() final  int absenceLimit;
@override@JsonKey() final  int currentAbsences;
@override@JsonKey() final  double progress;
@override final  String? iconName;
@override final  DateTime? createdAt;
@override final  DateTime? nextExamDate;
@override@JsonKey() final  int credits;
@override@JsonKey() final  String status;
// 'active', 'completed', 'archived'
 final  List<DateTime> _absenceDates;
// 'active', 'completed', 'archived'
@override@JsonKey() List<DateTime> get absenceDates {
  if (_absenceDates is EqualUnmodifiableListView) return _absenceDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_absenceDates);
}

@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CourseCopyWith<_Course> get copyWith => __$CourseCopyWithImpl<_Course>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Course&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.professor, professor) || other.professor == professor)&&(identical(other.location, location) || other.location == location)&&(identical(other.color, color) || other.color == color)&&const DeepCollectionEquality().equals(other._scheduleDays, _scheduleDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.absenceLimit, absenceLimit) || other.absenceLimit == absenceLimit)&&(identical(other.currentAbsences, currentAbsences) || other.currentAbsences == currentAbsences)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.nextExamDate, nextExamDate) || other.nextExamDate == nextExamDate)&&(identical(other.credits, credits) || other.credits == credits)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._absenceDates, _absenceDates)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,name,subtitle,professor,location,color,const DeepCollectionEquality().hash(_scheduleDays),startTime,endTime,absenceLimit,currentAbsences,progress,iconName,createdAt,nextExamDate,credits,status,const DeepCollectionEquality().hash(_absenceDates),latitude,longitude]);

@override
String toString() {
  return 'Course(id: $id, name: $name, subtitle: $subtitle, professor: $professor, location: $location, color: $color, scheduleDays: $scheduleDays, startTime: $startTime, endTime: $endTime, absenceLimit: $absenceLimit, currentAbsences: $currentAbsences, progress: $progress, iconName: $iconName, createdAt: $createdAt, nextExamDate: $nextExamDate, credits: $credits, status: $status, absenceDates: $absenceDates, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$CourseCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$CourseCopyWith(_Course value, $Res Function(_Course) _then) = __$CourseCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? subtitle, String? professor, String? location, Color color, List<int> scheduleDays, TimeOfDay startTime, TimeOfDay endTime, int absenceLimit, int currentAbsences, double progress, String? iconName, DateTime? createdAt, DateTime? nextExamDate, int credits, String status, List<DateTime> absenceDates, double? latitude, double? longitude
});




}
/// @nodoc
class __$CourseCopyWithImpl<$Res>
    implements _$CourseCopyWith<$Res> {
  __$CourseCopyWithImpl(this._self, this._then);

  final _Course _self;
  final $Res Function(_Course) _then;

/// Create a copy of Course
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? subtitle = freezed,Object? professor = freezed,Object? location = freezed,Object? color = null,Object? scheduleDays = null,Object? startTime = null,Object? endTime = null,Object? absenceLimit = null,Object? currentAbsences = null,Object? progress = null,Object? iconName = freezed,Object? createdAt = freezed,Object? nextExamDate = freezed,Object? credits = null,Object? status = null,Object? absenceDates = null,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_Course(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,professor: freezed == professor ? _self.professor : professor // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,scheduleDays: null == scheduleDays ? _self._scheduleDays : scheduleDays // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as TimeOfDay,absenceLimit: null == absenceLimit ? _self.absenceLimit : absenceLimit // ignore: cast_nullable_to_non_nullable
as int,currentAbsences: null == currentAbsences ? _self.currentAbsences : currentAbsences // ignore: cast_nullable_to_non_nullable
as int,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,iconName: freezed == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextExamDate: freezed == nextExamDate ? _self.nextExamDate : nextExamDate // ignore: cast_nullable_to_non_nullable
as DateTime?,credits: null == credits ? _self.credits : credits // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,absenceDates: null == absenceDates ? _self._absenceDates : absenceDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
