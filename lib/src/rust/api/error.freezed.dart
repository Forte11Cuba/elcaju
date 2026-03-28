// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Error {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ErrorCopyWith<$Res> {
  factory $ErrorCopyWith(Error value, $Res Function(Error) then) =
      _$ErrorCopyWithImpl<$Res, Error>;
}

/// @nodoc
class _$ErrorCopyWithImpl<$Res, $Val extends Error>
    implements $ErrorCopyWith<$Res> {
  _$ErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$Error_CdkImplCopyWith<$Res> {
  factory _$$Error_CdkImplCopyWith(
    _$Error_CdkImpl value,
    $Res Function(_$Error_CdkImpl) then,
  ) = __$$Error_CdkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$Error_CdkImplCopyWithImpl<$Res>
    extends _$ErrorCopyWithImpl<$Res, _$Error_CdkImpl>
    implements _$$Error_CdkImplCopyWith<$Res> {
  __$$Error_CdkImplCopyWithImpl(
    _$Error_CdkImpl _value,
    $Res Function(_$Error_CdkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Error_CdkImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$Error_CdkImpl extends Error_Cdk {
  const _$Error_CdkImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'Error.cdk(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error_CdkImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Error_CdkImplCopyWith<_$Error_CdkImpl> get copyWith =>
      __$$Error_CdkImplCopyWithImpl<_$Error_CdkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) {
    return cdk(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) {
    return cdk?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) {
    if (cdk != null) {
      return cdk(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) {
    return cdk(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) {
    return cdk?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) {
    if (cdk != null) {
      return cdk(this);
    }
    return orElse();
  }
}

abstract class Error_Cdk extends Error {
  const factory Error_Cdk(final String field0) = _$Error_CdkImpl;
  const Error_Cdk._() : super._();

  String get field0;

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Error_CdkImplCopyWith<_$Error_CdkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Error_DatabaseImplCopyWith<$Res> {
  factory _$$Error_DatabaseImplCopyWith(
    _$Error_DatabaseImpl value,
    $Res Function(_$Error_DatabaseImpl) then,
  ) = __$$Error_DatabaseImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$Error_DatabaseImplCopyWithImpl<$Res>
    extends _$ErrorCopyWithImpl<$Res, _$Error_DatabaseImpl>
    implements _$$Error_DatabaseImplCopyWith<$Res> {
  __$$Error_DatabaseImplCopyWithImpl(
    _$Error_DatabaseImpl _value,
    $Res Function(_$Error_DatabaseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Error_DatabaseImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$Error_DatabaseImpl extends Error_Database {
  const _$Error_DatabaseImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'Error.database(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error_DatabaseImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Error_DatabaseImplCopyWith<_$Error_DatabaseImpl> get copyWith =>
      __$$Error_DatabaseImplCopyWithImpl<_$Error_DatabaseImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) {
    return database(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) {
    return database?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) {
    return database(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) {
    return database?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) {
    if (database != null) {
      return database(this);
    }
    return orElse();
  }
}

abstract class Error_Database extends Error {
  const factory Error_Database(final String field0) = _$Error_DatabaseImpl;
  const Error_Database._() : super._();

  String get field0;

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Error_DatabaseImplCopyWith<_$Error_DatabaseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Error_InvalidInputImplCopyWith<$Res> {
  factory _$$Error_InvalidInputImplCopyWith(
    _$Error_InvalidInputImpl value,
    $Res Function(_$Error_InvalidInputImpl) then,
  ) = __$$Error_InvalidInputImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$Error_InvalidInputImplCopyWithImpl<$Res>
    extends _$ErrorCopyWithImpl<$Res, _$Error_InvalidInputImpl>
    implements _$$Error_InvalidInputImplCopyWith<$Res> {
  __$$Error_InvalidInputImplCopyWithImpl(
    _$Error_InvalidInputImpl _value,
    $Res Function(_$Error_InvalidInputImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$Error_InvalidInputImpl extends Error_InvalidInput {
  const _$Error_InvalidInputImpl() : super._();

  @override
  String toString() {
    return 'Error.invalidInput()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Error_InvalidInputImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) {
    return invalidInput();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) {
    return invalidInput?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) {
    if (invalidInput != null) {
      return invalidInput();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) {
    return invalidInput(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) {
    return invalidInput?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) {
    if (invalidInput != null) {
      return invalidInput(this);
    }
    return orElse();
  }
}

abstract class Error_InvalidInput extends Error {
  const factory Error_InvalidInput() = _$Error_InvalidInputImpl;
  const Error_InvalidInput._() : super._();
}

/// @nodoc
abstract class _$$Error_NetworkImplCopyWith<$Res> {
  factory _$$Error_NetworkImplCopyWith(
    _$Error_NetworkImpl value,
    $Res Function(_$Error_NetworkImpl) then,
  ) = __$$Error_NetworkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$Error_NetworkImplCopyWithImpl<$Res>
    extends _$ErrorCopyWithImpl<$Res, _$Error_NetworkImpl>
    implements _$$Error_NetworkImplCopyWith<$Res> {
  __$$Error_NetworkImplCopyWithImpl(
    _$Error_NetworkImpl _value,
    $Res Function(_$Error_NetworkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Error_NetworkImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$Error_NetworkImpl extends Error_Network {
  const _$Error_NetworkImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'Error.network(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error_NetworkImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Error_NetworkImplCopyWith<_$Error_NetworkImpl> get copyWith =>
      __$$Error_NetworkImplCopyWithImpl<_$Error_NetworkImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) {
    return network(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) {
    return network?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class Error_Network extends Error {
  const factory Error_Network(final String field0) = _$Error_NetworkImpl;
  const Error_Network._() : super._();

  String get field0;

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Error_NetworkImplCopyWith<_$Error_NetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$Error_UrImplCopyWith<$Res> {
  factory _$$Error_UrImplCopyWith(
    _$Error_UrImpl value,
    $Res Function(_$Error_UrImpl) then,
  ) = __$$Error_UrImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$Error_UrImplCopyWithImpl<$Res>
    extends _$ErrorCopyWithImpl<$Res, _$Error_UrImpl>
    implements _$$Error_UrImplCopyWith<$Res> {
  __$$Error_UrImplCopyWithImpl(
    _$Error_UrImpl _value,
    $Res Function(_$Error_UrImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$Error_UrImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$Error_UrImpl extends Error_Ur {
  const _$Error_UrImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'Error.ur(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Error_UrImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Error_UrImplCopyWith<_$Error_UrImpl> get copyWith =>
      __$$Error_UrImplCopyWithImpl<_$Error_UrImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) cdk,
    required TResult Function(String field0) database,
    required TResult Function() invalidInput,
    required TResult Function(String field0) network,
    required TResult Function(String field0) ur,
  }) {
    return ur(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? cdk,
    TResult? Function(String field0)? database,
    TResult? Function()? invalidInput,
    TResult? Function(String field0)? network,
    TResult? Function(String field0)? ur,
  }) {
    return ur?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? cdk,
    TResult Function(String field0)? database,
    TResult Function()? invalidInput,
    TResult Function(String field0)? network,
    TResult Function(String field0)? ur,
    required TResult orElse(),
  }) {
    if (ur != null) {
      return ur(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Error_Cdk value) cdk,
    required TResult Function(Error_Database value) database,
    required TResult Function(Error_InvalidInput value) invalidInput,
    required TResult Function(Error_Network value) network,
    required TResult Function(Error_Ur value) ur,
  }) {
    return ur(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Error_Cdk value)? cdk,
    TResult? Function(Error_Database value)? database,
    TResult? Function(Error_InvalidInput value)? invalidInput,
    TResult? Function(Error_Network value)? network,
    TResult? Function(Error_Ur value)? ur,
  }) {
    return ur?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Error_Cdk value)? cdk,
    TResult Function(Error_Database value)? database,
    TResult Function(Error_InvalidInput value)? invalidInput,
    TResult Function(Error_Network value)? network,
    TResult Function(Error_Ur value)? ur,
    required TResult orElse(),
  }) {
    if (ur != null) {
      return ur(this);
    }
    return orElse();
  }
}

abstract class Error_Ur extends Error {
  const factory Error_Ur(final String field0) = _$Error_UrImpl;
  const Error_Ur._() : super._();

  String get field0;

  /// Create a copy of Error
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Error_UrImplCopyWith<_$Error_UrImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
