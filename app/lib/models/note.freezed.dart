// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark
// 
// ⚠️ NOTE: This file is manually updated to add cloudPath and thumbnailCloudPath fields.
// Run `flutter pub run build_runner build` to regenerate properly.

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Note {

 String get id; String get courseId; NoteType get type; String get title; String? get content;// Metin içeriği (OCR sonucu dahil)
  String? get filePath;// Ses/resim dosya yolu
  String? get thumbnailPath;// Önizleme resmi
  int? get audioDuration;// Ses süresi (saniye)
  List<String> get tags; List<Duration> get bookmarks; bool get isBookmarked; DateTime? get createdAt; DateTime? get updatedAt; String? get drawingData; String? get cloudPath;// E2E encrypted cloud path
  String? get thumbnailCloudPath;// E2E encrypted thumbnail cloud path
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.bookmarks, bookmarks)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.drawingData, drawingData) || other.drawingData == drawingData)&&(identical(other.cloudPath, cloudPath) || other.cloudPath == cloudPath)&&(identical(other.thumbnailCloudPath, thumbnailCloudPath) || other.thumbnailCloudPath == thumbnailCloudPath));
}


@override
int get hashCode => Object.hash(runtimeType,id,courseId,type,title,content,filePath,thumbnailPath,audioDuration,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(bookmarks),isBookmarked,createdAt,updatedAt,drawingData,cloudPath,thumbnailCloudPath);

@override
String toString() {
  return 'Note(id: $id, courseId: $courseId, type: $type, title: $title, content: $content, filePath: $filePath, thumbnailPath: $thumbnailPath, audioDuration: $audioDuration, tags: $tags, bookmarks: $bookmarks, isBookmarked: $isBookmarked, createdAt: $createdAt, updatedAt: $updatedAt, drawingData: $drawingData, cloudPath: $cloudPath, thumbnailCloudPath: $thumbnailCloudPath)';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 String id, String courseId, NoteType type, String title, String? content, String? filePath, String? thumbnailPath, int? audioDuration, List<String> tags, List<Duration> bookmarks, bool isBookmarked, DateTime? createdAt, DateTime? updatedAt, String? drawingData, String? cloudPath, String? thumbnailCloudPath
});




}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? courseId = null,Object? type = null,Object? title = null,Object? content = freezed,Object? filePath = freezed,Object? thumbnailPath = freezed,Object? audioDuration = freezed,Object? tags = null,Object? bookmarks = null,Object? isBookmarked = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? drawingData = freezed,Object? cloudPath = freezed,Object? thumbnailCloudPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NoteType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as int?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Duration>,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,drawingData: freezed == drawingData ? _self.drawingData : drawingData // ignore: cast_nullable_to_non_nullable
as String?,cloudPath: freezed == cloudPath ? _self.cloudPath : cloudPath // ignore: cast_nullable_to_non_nullable
as String?,thumbnailCloudPath: freezed == thumbnailCloudPath ? _self.thumbnailCloudPath : thumbnailCloudPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Note value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Note value)  $default,){
final _that = this;
switch (_that) {
case _Note():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Note value)?  $default,){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String courseId,  NoteType type,  String title,  String? content,  String? filePath,  String? thumbnailPath,  int? audioDuration,  List<String> tags,  List<Duration> bookmarks,  bool isBookmarked,  DateTime? createdAt,  DateTime? updatedAt,  String? drawingData,  String? cloudPath,  String? thumbnailCloudPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.courseId,_that.type,_that.title,_that.content,_that.filePath,_that.thumbnailPath,_that.audioDuration,_that.tags,_that.bookmarks,_that.isBookmarked,_that.createdAt,_that.updatedAt,_that.drawingData,_that.cloudPath,_that.thumbnailCloudPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String courseId,  NoteType type,  String title,  String? content,  String? filePath,  String? thumbnailPath,  int? audioDuration,  List<String> tags,  List<Duration> bookmarks,  bool isBookmarked,  DateTime? createdAt,  DateTime? updatedAt,  String? drawingData,  String? cloudPath,  String? thumbnailCloudPath)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.courseId,_that.type,_that.title,_that.content,_that.filePath,_that.thumbnailPath,_that.audioDuration,_that.tags,_that.bookmarks,_that.isBookmarked,_that.createdAt,_that.updatedAt,_that.drawingData,_that.cloudPath,_that.thumbnailCloudPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String courseId,  NoteType type,  String title,  String? content,  String? filePath,  String? thumbnailPath,  int? audioDuration,  List<String> tags,  List<Duration> bookmarks,  bool isBookmarked,  DateTime? createdAt,  DateTime? updatedAt,  String? drawingData,  String? cloudPath,  String? thumbnailCloudPath)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.courseId,_that.type,_that.title,_that.content,_that.filePath,_that.thumbnailPath,_that.audioDuration,_that.tags,_that.bookmarks,_that.isBookmarked,_that.createdAt,_that.updatedAt,_that.drawingData,_that.cloudPath,_that.thumbnailCloudPath);case _:
  return null;

}
}

}

/// @nodoc


class _Note extends Note {
  const _Note({required this.id, required this.courseId, required this.type, required this.title, this.content, this.filePath, this.thumbnailPath, this.audioDuration, final  List<String> tags = const [], final  List<Duration> bookmarks = const [], this.isBookmarked = false, this.createdAt, this.updatedAt, this.drawingData, this.cloudPath, this.thumbnailCloudPath}): _tags = tags,_bookmarks = bookmarks,super._();
  

@override final  String id;
@override final  String courseId;
@override final  NoteType type;
@override final  String title;
@override final  String? content;
// Metin içeriği (OCR sonucu dahil)
@override final  String? filePath;
// Ses/resim dosya yolu
@override final  String? thumbnailPath;
// Önizleme resmi
@override final  int? audioDuration;
// Ses süresi (saniye)
 final  List<String> _tags;
// Ses süresi (saniye)
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<Duration> _bookmarks;
@override@JsonKey() List<Duration> get bookmarks {
  if (_bookmarks is EqualUnmodifiableListView) return _bookmarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookmarks);
}

@override@JsonKey() final  bool isBookmarked;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  String? drawingData;
// E2E encrypted cloud path
@override final  String? cloudPath;
// E2E encrypted thumbnail cloud path
@override final  String? thumbnailCloudPath;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCopyWith<_Note> get copyWith => __$NoteCopyWithImpl<_Note>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.courseId, courseId) || other.courseId == courseId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.thumbnailPath, thumbnailPath) || other.thumbnailPath == thumbnailPath)&&(identical(other.audioDuration, audioDuration) || other.audioDuration == audioDuration)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._bookmarks, _bookmarks)&&(identical(other.isBookmarked, isBookmarked) || other.isBookmarked == isBookmarked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.drawingData, drawingData) || other.drawingData == drawingData)&&(identical(other.cloudPath, cloudPath) || other.cloudPath == cloudPath)&&(identical(other.thumbnailCloudPath, thumbnailCloudPath) || other.thumbnailCloudPath == thumbnailCloudPath));
}


@override
int get hashCode => Object.hash(runtimeType,id,courseId,type,title,content,filePath,thumbnailPath,audioDuration,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_bookmarks),isBookmarked,createdAt,updatedAt,drawingData,cloudPath,thumbnailCloudPath);

@override
String toString() {
  return 'Note(id: $id, courseId: $courseId, type: $type, title: $title, content: $content, filePath: $filePath, thumbnailPath: $thumbnailPath, audioDuration: $audioDuration, tags: $tags, bookmarks: $bookmarks, isBookmarked: $isBookmarked, createdAt: $createdAt, updatedAt: $updatedAt, drawingData: $drawingData, cloudPath: $cloudPath, thumbnailCloudPath: $thumbnailCloudPath)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String courseId, NoteType type, String title, String? content, String? filePath, String? thumbnailPath, int? audioDuration, List<String> tags, List<Duration> bookmarks, bool isBookmarked, DateTime? createdAt, DateTime? updatedAt, String? drawingData, String? cloudPath, String? thumbnailCloudPath
});




}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? courseId = null,Object? type = null,Object? title = null,Object? content = freezed,Object? filePath = freezed,Object? thumbnailPath = freezed,Object? audioDuration = freezed,Object? tags = null,Object? bookmarks = null,Object? isBookmarked = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? drawingData = freezed,Object? cloudPath = freezed,Object? thumbnailCloudPath = freezed,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,courseId: null == courseId ? _self.courseId : courseId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NoteType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,thumbnailPath: freezed == thumbnailPath ? _self.thumbnailPath : thumbnailPath // ignore: cast_nullable_to_non_nullable
as String?,audioDuration: freezed == audioDuration ? _self.audioDuration : audioDuration // ignore: cast_nullable_to_non_nullable
as int?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,bookmarks: null == bookmarks ? _self._bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as List<Duration>,isBookmarked: null == isBookmarked ? _self.isBookmarked : isBookmarked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,drawingData: freezed == drawingData ? _self.drawingData : drawingData // ignore: cast_nullable_to_non_nullable
as String?,cloudPath: freezed == cloudPath ? _self.cloudPath : cloudPath // ignore: cast_nullable_to_non_nullable
as String?,thumbnailCloudPath: freezed == thumbnailCloudPath ? _self.thumbnailCloudPath : thumbnailCloudPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
