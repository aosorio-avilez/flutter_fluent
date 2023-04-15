// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rest_api_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$RestApiResult<T> {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) succeeded,
    required TResult Function(Object data) failed,
    required TResult Function(RestApiError error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? succeeded,
    TResult? Function(Object data)? failed,
    TResult? Function(RestApiError error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? succeeded,
    TResult Function(Object data)? failed,
    TResult Function(RestApiError error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Succeeded<T> value) succeeded,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Error<T> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Succeeded<T> value)? succeeded,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Error<T> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Succeeded<T> value)? succeeded,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestApiResultCopyWith<T, $Res> {
  factory $RestApiResultCopyWith(
          RestApiResult<T> value, $Res Function(RestApiResult<T>) then) =
      _$RestApiResultCopyWithImpl<T, $Res, RestApiResult<T>>;
}

/// @nodoc
class _$RestApiResultCopyWithImpl<T, $Res, $Val extends RestApiResult<T>>
    implements $RestApiResultCopyWith<T, $Res> {
  _$RestApiResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SucceededCopyWith<T, $Res> {
  factory _$$SucceededCopyWith(
          _$Succeeded<T> value, $Res Function(_$Succeeded<T>) then) =
      __$$SucceededCopyWithImpl<T, $Res>;
  @useResult
  $Res call({T data});
}

/// @nodoc
class __$$SucceededCopyWithImpl<T, $Res>
    extends _$RestApiResultCopyWithImpl<T, $Res, _$Succeeded<T>>
    implements _$$SucceededCopyWith<T, $Res> {
  __$$SucceededCopyWithImpl(
      _$Succeeded<T> _value, $Res Function(_$Succeeded<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
  }) {
    return _then(_$Succeeded<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$Succeeded<T> implements Succeeded<T> {
  const _$Succeeded(this.data);

  @override
  final T data;

  @override
  String toString() {
    return 'RestApiResult<$T>.succeeded(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Succeeded<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SucceededCopyWith<T, _$Succeeded<T>> get copyWith =>
      __$$SucceededCopyWithImpl<T, _$Succeeded<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) succeeded,
    required TResult Function(Object data) failed,
    required TResult Function(RestApiError error) error,
  }) {
    return succeeded(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? succeeded,
    TResult? Function(Object data)? failed,
    TResult? Function(RestApiError error)? error,
  }) {
    return succeeded?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? succeeded,
    TResult Function(Object data)? failed,
    TResult Function(RestApiError error)? error,
    required TResult orElse(),
  }) {
    if (succeeded != null) {
      return succeeded(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Succeeded<T> value) succeeded,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Error<T> value) error,
  }) {
    return succeeded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Succeeded<T> value)? succeeded,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Error<T> value)? error,
  }) {
    return succeeded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Succeeded<T> value)? succeeded,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (succeeded != null) {
      return succeeded(this);
    }
    return orElse();
  }
}

abstract class Succeeded<T> implements RestApiResult<T> {
  const factory Succeeded(final T data) = _$Succeeded<T>;

  T get data;
  @JsonKey(ignore: true)
  _$$SucceededCopyWith<T, _$Succeeded<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailedCopyWith<T, $Res> {
  factory _$$FailedCopyWith(
          _$Failed<T> value, $Res Function(_$Failed<T>) then) =
      __$$FailedCopyWithImpl<T, $Res>;
  @useResult
  $Res call({Object data});
}

/// @nodoc
class __$$FailedCopyWithImpl<T, $Res>
    extends _$RestApiResultCopyWithImpl<T, $Res, _$Failed<T>>
    implements _$$FailedCopyWith<T, $Res> {
  __$$FailedCopyWithImpl(_$Failed<T> _value, $Res Function(_$Failed<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$Failed<T>(
      null == data ? _value.data : data,
    ));
  }
}

/// @nodoc

class _$Failed<T> implements Failed<T> {
  const _$Failed(this.data);

  @override
  final Object data;

  @override
  String toString() {
    return 'RestApiResult<$T>.failed(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Failed<T> &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FailedCopyWith<T, _$Failed<T>> get copyWith =>
      __$$FailedCopyWithImpl<T, _$Failed<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) succeeded,
    required TResult Function(Object data) failed,
    required TResult Function(RestApiError error) error,
  }) {
    return failed(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? succeeded,
    TResult? Function(Object data)? failed,
    TResult? Function(RestApiError error)? error,
  }) {
    return failed?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? succeeded,
    TResult Function(Object data)? failed,
    TResult Function(RestApiError error)? error,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Succeeded<T> value) succeeded,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Error<T> value) error,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Succeeded<T> value)? succeeded,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Error<T> value)? error,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Succeeded<T> value)? succeeded,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class Failed<T> implements RestApiResult<T> {
  const factory Failed(final Object data) = _$Failed<T>;

  Object get data;
  @JsonKey(ignore: true)
  _$$FailedCopyWith<T, _$Failed<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorCopyWith<T, $Res> {
  factory _$$ErrorCopyWith(_$Error<T> value, $Res Function(_$Error<T>) then) =
      __$$ErrorCopyWithImpl<T, $Res>;
  @useResult
  $Res call({RestApiError error});
}

/// @nodoc
class __$$ErrorCopyWithImpl<T, $Res>
    extends _$RestApiResultCopyWithImpl<T, $Res, _$Error<T>>
    implements _$$ErrorCopyWith<T, $Res> {
  __$$ErrorCopyWithImpl(_$Error<T> _value, $Res Function(_$Error<T>) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$Error<T>(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as RestApiError,
    ));
  }
}

/// @nodoc

class _$Error<T> implements Error<T> {
  const _$Error(this.error);

  @override
  final RestApiError error;

  @override
  String toString() {
    return 'RestApiResult<$T>.error(error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error<T> &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorCopyWith<T, _$Error<T>> get copyWith =>
      __$$ErrorCopyWithImpl<T, _$Error<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T data) succeeded,
    required TResult Function(Object data) failed,
    required TResult Function(RestApiError error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T data)? succeeded,
    TResult? Function(Object data)? failed,
    TResult? Function(RestApiError error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T data)? succeeded,
    TResult Function(Object data)? failed,
    TResult Function(RestApiError error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Succeeded<T> value) succeeded,
    required TResult Function(Failed<T> value) failed,
    required TResult Function(Error<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Succeeded<T> value)? succeeded,
    TResult? Function(Failed<T> value)? failed,
    TResult? Function(Error<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Succeeded<T> value)? succeeded,
    TResult Function(Failed<T> value)? failed,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error<T> implements RestApiResult<T> {
  const factory Error(final RestApiError error) = _$Error<T>;

  RestApiError get error;
  @JsonKey(ignore: true)
  _$$ErrorCopyWith<T, _$Error<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
