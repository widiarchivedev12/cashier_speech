// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Cart {
  List<CartItem> get items;
  int? get paid;
  String? get rawTranscript;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CartCopyWith<Cart> get copyWith =>
      _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as Cart;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Cart &&
            const DeepCollectionEquality().equals(other.items, _this.items) &&
            (identical(other.paid, _this.paid) || other.paid == _this.paid) &&
            (identical(other.rawTranscript, _this.rawTranscript) ||
                other.rawTranscript == _this.rawTranscript));
  }

  @override
  int get hashCode {
    final _this = this as Cart;
    return Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(_this.items),
        _this.paid,
        _this.rawTranscript);
  }

  @override
  String toString() {
    final _this = this as Cart;
    return 'Cart(items: ${_this.items}, paid: ${_this.paid}, rawTranscript: ${_this.rawTranscript})';
  }
}

/// @nodoc
abstract mixin class $CartCopyWith<$Res> {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) =
      _$CartCopyWithImpl;
  @useResult
  $Res call({List<CartItem> items, int? paid, String? rawTranscript});
}

/// @nodoc
class _$CartCopyWithImpl<$Res> implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? paid = freezed,
    Object? rawTranscript = freezed,
  }) {
    return _then(Cart(
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      paid: freezed == paid
          ? _self.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as int?,
      rawTranscript: freezed == rawTranscript
          ? _self.rawTranscript
          : rawTranscript // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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
    TResult Function(_Cart value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Cart() when $default != null:
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
    TResult Function(_Cart value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cart():
        return $default(_that);
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
    TResult? Function(_Cart value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cart() when $default != null:
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
    TResult Function(List<CartItem> items, int? paid, String? rawTranscript)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Cart() when $default != null:
        return $default(_that.items, _that.paid, _that.rawTranscript);
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
    TResult Function(List<CartItem> items, int? paid, String? rawTranscript)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cart():
        return $default(_that.items, _that.paid, _that.rawTranscript);
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
    TResult? Function(List<CartItem> items, int? paid, String? rawTranscript)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Cart() when $default != null:
        return $default(_that.items, _that.paid, _that.rawTranscript);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Cart implements Cart {
  const _Cart({List<CartItem> items = const [], this.paid, this.rawTranscript})
      : _items = items;

  final List<CartItem> _items;
  @override
  @JsonKey()
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final int? paid;
  @override
  final String? rawTranscript;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CartCopyWith<_Cart> get copyWith =>
      __$CartCopyWithImpl<_Cart>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Cart &&
            const DeepCollectionEquality().equals(other.items, _items) &&
            (identical(other.paid, paid) || other.paid == paid) &&
            (identical(other.rawTranscript, rawTranscript) ||
                other.rawTranscript == rawTranscript));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, const DeepCollectionEquality().hash(_items),
        paid, rawTranscript);
  }

  @override
  String toString() {
    return 'Cart(items: $items, paid: $paid, rawTranscript: $rawTranscript)';
  }
}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) =
      __$CartCopyWithImpl;
  @override
  @useResult
  $Res call({List<CartItem> items, int? paid, String? rawTranscript});
}

/// @nodoc
class __$CartCopyWithImpl<$Res> implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? paid = freezed,
    Object? rawTranscript = freezed,
  }) {
    return _then(_Cart(
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CartItem>,
      paid: freezed == paid
          ? _self.paid
          : paid // ignore: cast_nullable_to_non_nullable
              as int?,
      rawTranscript: freezed == rawTranscript
          ? _self.rawTranscript
          : rawTranscript // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
