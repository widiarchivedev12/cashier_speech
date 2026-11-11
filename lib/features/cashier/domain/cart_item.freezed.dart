// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartItem {
  String get id;
  String get productId;
  String get productName;
  int get unitPrice;
  int get qty;
  int? get lineTotalOverride;
  double? get confidence;
  String? get sourceText;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CartItemCopyWith<CartItem> get copyWith =>
      _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as CartItem;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CartItem &&
            (identical(other.id, _this.id) || other.id == _this.id) &&
            (identical(other.productId, _this.productId) ||
                other.productId == _this.productId) &&
            (identical(other.productName, _this.productName) ||
                other.productName == _this.productName) &&
            (identical(other.unitPrice, _this.unitPrice) ||
                other.unitPrice == _this.unitPrice) &&
            (identical(other.qty, _this.qty) || other.qty == _this.qty) &&
            (identical(other.lineTotalOverride, _this.lineTotalOverride) ||
                other.lineTotalOverride == _this.lineTotalOverride) &&
            (identical(other.confidence, _this.confidence) ||
                other.confidence == _this.confidence) &&
            (identical(other.sourceText, _this.sourceText) ||
                other.sourceText == _this.sourceText));
  }

  @override
  int get hashCode {
    final _this = this as CartItem;
    return Object.hash(
        runtimeType,
        _this.id,
        _this.productId,
        _this.productName,
        _this.unitPrice,
        _this.qty,
        _this.lineTotalOverride,
        _this.confidence,
        _this.sourceText);
  }

  @override
  String toString() {
    final _this = this as CartItem;
    return 'CartItem(id: ${_this.id}, productId: ${_this.productId}, productName: ${_this.productName}, unitPrice: ${_this.unitPrice}, qty: ${_this.qty}, lineTotalOverride: ${_this.lineTotalOverride}, confidence: ${_this.confidence}, sourceText: ${_this.sourceText})';
  }
}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) =
      _$CartItemCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      int unitPrice,
      int qty,
      int? lineTotalOverride,
      double? confidence,
      String? sourceText});
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res> implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? unitPrice = null,
    Object? qty = null,
    Object? lineTotalOverride = freezed,
    Object? confidence = freezed,
    Object? sourceText = freezed,
  }) {
    return _then(CartItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as int,
      lineTotalOverride: freezed == lineTotalOverride
          ? _self.lineTotalOverride
          : lineTotalOverride // ignore: cast_nullable_to_non_nullable
              as int?,
      confidence: freezed == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      sourceText: freezed == sourceText
          ? _self.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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
    TResult Function(_CartItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CartItem() when $default != null:
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
    TResult Function(_CartItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CartItem():
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
    TResult? Function(_CartItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CartItem() when $default != null:
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
    TResult Function(
            String id,
            String productId,
            String productName,
            int unitPrice,
            int qty,
            int? lineTotalOverride,
            double? confidence,
            String? sourceText)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CartItem() when $default != null:
        return $default(
            _that.id,
            _that.productId,
            _that.productName,
            _that.unitPrice,
            _that.qty,
            _that.lineTotalOverride,
            _that.confidence,
            _that.sourceText);
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
    TResult Function(
            String id,
            String productId,
            String productName,
            int unitPrice,
            int qty,
            int? lineTotalOverride,
            double? confidence,
            String? sourceText)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CartItem():
        return $default(
            _that.id,
            _that.productId,
            _that.productName,
            _that.unitPrice,
            _that.qty,
            _that.lineTotalOverride,
            _that.confidence,
            _that.sourceText);
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
    TResult? Function(
            String id,
            String productId,
            String productName,
            int unitPrice,
            int qty,
            int? lineTotalOverride,
            double? confidence,
            String? sourceText)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CartItem() when $default != null:
        return $default(
            _that.id,
            _that.productId,
            _that.productName,
            _that.unitPrice,
            _that.qty,
            _that.lineTotalOverride,
            _that.confidence,
            _that.sourceText);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CartItem implements CartItem {
  const _CartItem(
      {required this.id,
      required this.productId,
      required this.productName,
      required this.unitPrice,
      required this.qty,
      this.lineTotalOverride,
      this.confidence,
      this.sourceText});

  @override
  final String id;
  @override
  final String productId;
  @override
  final String productName;
  @override
  final int unitPrice;
  @override
  final int qty;
  @override
  final int? lineTotalOverride;
  @override
  final double? confidence;
  @override
  final String? sourceText;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CartItemCopyWith<_CartItem> get copyWith =>
      __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CartItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.qty, qty) || other.qty == qty) &&
            (identical(other.lineTotalOverride, lineTotalOverride) ||
                other.lineTotalOverride == lineTotalOverride) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.sourceText, sourceText) ||
                other.sourceText == sourceText));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, id, productId, productName, unitPrice, qty,
        lineTotalOverride, confidence, sourceText);
  }

  @override
  String toString() {
    return 'CartItem(id: $id, productId: $productId, productName: $productName, unitPrice: $unitPrice, qty: $qty, lineTotalOverride: $lineTotalOverride, confidence: $confidence, sourceText: $sourceText)';
  }
}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) =
      __$CartItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String productName,
      int unitPrice,
      int qty,
      int? lineTotalOverride,
      double? confidence,
      String? sourceText});
}

/// @nodoc
class __$CartItemCopyWithImpl<$Res> implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? productName = null,
    Object? unitPrice = null,
    Object? qty = null,
    Object? lineTotalOverride = freezed,
    Object? confidence = freezed,
    Object? sourceText = freezed,
  }) {
    return _then(_CartItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _self.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      unitPrice: null == unitPrice
          ? _self.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      qty: null == qty
          ? _self.qty
          : qty // ignore: cast_nullable_to_non_nullable
              as int,
      lineTotalOverride: freezed == lineTotalOverride
          ? _self.lineTotalOverride
          : lineTotalOverride // ignore: cast_nullable_to_non_nullable
              as int?,
      confidence: freezed == confidence
          ? _self.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double?,
      sourceText: freezed == sourceText
          ? _self.sourceText
          : sourceText // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
