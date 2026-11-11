// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DailyReport {
  DateTime get date;
  int get totalRevenue;
  int get transactionCount;
  int get voiceCount;
  List<ProductSummary> get topProducts;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DailyReportCopyWith<DailyReport> get copyWith =>
      _$DailyReportCopyWithImpl<DailyReport>(this as DailyReport, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as DailyReport;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DailyReport &&
            (identical(other.date, _this.date) || other.date == _this.date) &&
            (identical(other.totalRevenue, _this.totalRevenue) ||
                other.totalRevenue == _this.totalRevenue) &&
            (identical(other.transactionCount, _this.transactionCount) ||
                other.transactionCount == _this.transactionCount) &&
            (identical(other.voiceCount, _this.voiceCount) ||
                other.voiceCount == _this.voiceCount) &&
            const DeepCollectionEquality()
                .equals(other.topProducts, _this.topProducts));
  }

  @override
  int get hashCode {
    final _this = this as DailyReport;
    return Object.hash(
        runtimeType,
        _this.date,
        _this.totalRevenue,
        _this.transactionCount,
        _this.voiceCount,
        const DeepCollectionEquality().hash(_this.topProducts));
  }

  @override
  String toString() {
    final _this = this as DailyReport;
    return 'DailyReport(date: ${_this.date}, totalRevenue: ${_this.totalRevenue}, transactionCount: ${_this.transactionCount}, voiceCount: ${_this.voiceCount}, topProducts: ${_this.topProducts})';
  }
}

/// @nodoc
abstract mixin class $DailyReportCopyWith<$Res> {
  factory $DailyReportCopyWith(
          DailyReport value, $Res Function(DailyReport) _then) =
      _$DailyReportCopyWithImpl;
  @useResult
  $Res call(
      {DateTime date,
      int totalRevenue,
      int transactionCount,
      int voiceCount,
      List<ProductSummary> topProducts});
}

/// @nodoc
class _$DailyReportCopyWithImpl<$Res> implements $DailyReportCopyWith<$Res> {
  _$DailyReportCopyWithImpl(this._self, this._then);

  final DailyReport _self;
  final $Res Function(DailyReport) _then;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? totalRevenue = null,
    Object? transactionCount = null,
    Object? voiceCount = null,
    Object? topProducts = null,
  }) {
    return _then(DailyReport(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalRevenue: null == totalRevenue
          ? _self.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      transactionCount: null == transactionCount
          ? _self.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      voiceCount: null == voiceCount
          ? _self.voiceCount
          : voiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      topProducts: null == topProducts
          ? _self.topProducts
          : topProducts // ignore: cast_nullable_to_non_nullable
              as List<ProductSummary>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DailyReport].
extension DailyReportPatterns on DailyReport {
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
    TResult Function(_DailyReport value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyReport() when $default != null:
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
    TResult Function(_DailyReport value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyReport():
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
    TResult? Function(_DailyReport value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyReport() when $default != null:
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
    TResult Function(DateTime date, int totalRevenue, int transactionCount,
            int voiceCount, List<ProductSummary> topProducts)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DailyReport() when $default != null:
        return $default(_that.date, _that.totalRevenue, _that.transactionCount,
            _that.voiceCount, _that.topProducts);
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
    TResult Function(DateTime date, int totalRevenue, int transactionCount,
            int voiceCount, List<ProductSummary> topProducts)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyReport():
        return $default(_that.date, _that.totalRevenue, _that.transactionCount,
            _that.voiceCount, _that.topProducts);
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
    TResult? Function(DateTime date, int totalRevenue, int transactionCount,
            int voiceCount, List<ProductSummary> topProducts)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DailyReport() when $default != null:
        return $default(_that.date, _that.totalRevenue, _that.transactionCount,
            _that.voiceCount, _that.topProducts);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DailyReport extends DailyReport {
  const _DailyReport(
      {required this.date,
      required this.totalRevenue,
      required this.transactionCount,
      required this.voiceCount,
      required List<ProductSummary> topProducts})
      : _topProducts = topProducts,
        super._();

  @override
  final DateTime date;
  @override
  final int totalRevenue;
  @override
  final int transactionCount;
  @override
  final int voiceCount;
  final List<ProductSummary> _topProducts;
  @override
  List<ProductSummary> get topProducts {
    if (_topProducts is EqualUnmodifiableListView) return _topProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topProducts);
  }

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DailyReportCopyWith<_DailyReport> get copyWith =>
      __$DailyReportCopyWithImpl<_DailyReport>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DailyReport &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.transactionCount, transactionCount) ||
                other.transactionCount == transactionCount) &&
            (identical(other.voiceCount, voiceCount) ||
                other.voiceCount == voiceCount) &&
            const DeepCollectionEquality()
                .equals(other.topProducts, _topProducts));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, date, totalRevenue, transactionCount,
        voiceCount, const DeepCollectionEquality().hash(_topProducts));
  }

  @override
  String toString() {
    return 'DailyReport(date: $date, totalRevenue: $totalRevenue, transactionCount: $transactionCount, voiceCount: $voiceCount, topProducts: $topProducts)';
  }
}

/// @nodoc
abstract mixin class _$DailyReportCopyWith<$Res>
    implements $DailyReportCopyWith<$Res> {
  factory _$DailyReportCopyWith(
          _DailyReport value, $Res Function(_DailyReport) _then) =
      __$DailyReportCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int totalRevenue,
      int transactionCount,
      int voiceCount,
      List<ProductSummary> topProducts});
}

/// @nodoc
class __$DailyReportCopyWithImpl<$Res> implements _$DailyReportCopyWith<$Res> {
  __$DailyReportCopyWithImpl(this._self, this._then);

  final _DailyReport _self;
  final $Res Function(_DailyReport) _then;

  /// Create a copy of DailyReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? date = null,
    Object? totalRevenue = null,
    Object? transactionCount = null,
    Object? voiceCount = null,
    Object? topProducts = null,
  }) {
    return _then(_DailyReport(
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalRevenue: null == totalRevenue
          ? _self.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
      transactionCount: null == transactionCount
          ? _self.transactionCount
          : transactionCount // ignore: cast_nullable_to_non_nullable
              as int,
      voiceCount: null == voiceCount
          ? _self.voiceCount
          : voiceCount // ignore: cast_nullable_to_non_nullable
              as int,
      topProducts: null == topProducts
          ? _self._topProducts
          : topProducts // ignore: cast_nullable_to_non_nullable
              as List<ProductSummary>,
    ));
  }
}

/// @nodoc
mixin _$ProductSummary {
  String get productName;
  int get totalQty;
  int get totalRevenue;

  /// Create a copy of ProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProductSummaryCopyWith<ProductSummary> get copyWith =>
      _$ProductSummaryCopyWithImpl<ProductSummary>(
          this as ProductSummary, _$identity);

  @override
  bool operator ==(Object other) {
    final _this = this as ProductSummary;
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProductSummary &&
            (identical(other.productName, _this.productName) ||
                other.productName == _this.productName) &&
            (identical(other.totalQty, _this.totalQty) ||
                other.totalQty == _this.totalQty) &&
            (identical(other.totalRevenue, _this.totalRevenue) ||
                other.totalRevenue == _this.totalRevenue));
  }

  @override
  int get hashCode {
    final _this = this as ProductSummary;
    return Object.hash(
        runtimeType, _this.productName, _this.totalQty, _this.totalRevenue);
  }

  @override
  String toString() {
    final _this = this as ProductSummary;
    return 'ProductSummary(productName: ${_this.productName}, totalQty: ${_this.totalQty}, totalRevenue: ${_this.totalRevenue})';
  }
}

/// @nodoc
abstract mixin class $ProductSummaryCopyWith<$Res> {
  factory $ProductSummaryCopyWith(
          ProductSummary value, $Res Function(ProductSummary) _then) =
      _$ProductSummaryCopyWithImpl;
  @useResult
  $Res call({String productName, int totalQty, int totalRevenue});
}

/// @nodoc
class _$ProductSummaryCopyWithImpl<$Res>
    implements $ProductSummaryCopyWith<$Res> {
  _$ProductSummaryCopyWithImpl(this._self, this._then);

  final ProductSummary _self;
  final $Res Function(ProductSummary) _then;

  /// Create a copy of ProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? totalQty = null,
    Object? totalRevenue = null,
  }) {
    return _then(ProductSummary(
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      totalQty: null == totalQty
          ? _self.totalQty
          : totalQty // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _self.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProductSummary].
extension ProductSummaryPatterns on ProductSummary {
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
    TResult Function(_ProductSummary value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProductSummary() when $default != null:
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
    TResult Function(_ProductSummary value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductSummary():
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
    TResult? Function(_ProductSummary value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductSummary() when $default != null:
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
    TResult Function(String productName, int totalQty, int totalRevenue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProductSummary() when $default != null:
        return $default(_that.productName, _that.totalQty, _that.totalRevenue);
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
    TResult Function(String productName, int totalQty, int totalRevenue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductSummary():
        return $default(_that.productName, _that.totalQty, _that.totalRevenue);
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
    TResult? Function(String productName, int totalQty, int totalRevenue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProductSummary() when $default != null:
        return $default(_that.productName, _that.totalQty, _that.totalRevenue);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProductSummary implements ProductSummary {
  const _ProductSummary(
      {required this.productName,
      required this.totalQty,
      required this.totalRevenue});

  @override
  final String productName;
  @override
  final int totalQty;
  @override
  final int totalRevenue;

  /// Create a copy of ProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProductSummaryCopyWith<_ProductSummary> get copyWith =>
      __$ProductSummaryCopyWithImpl<_ProductSummary>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProductSummary &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.totalQty, totalQty) ||
                other.totalQty == totalQty) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue));
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, productName, totalQty, totalRevenue);
  }

  @override
  String toString() {
    return 'ProductSummary(productName: $productName, totalQty: $totalQty, totalRevenue: $totalRevenue)';
  }
}

/// @nodoc
abstract mixin class _$ProductSummaryCopyWith<$Res>
    implements $ProductSummaryCopyWith<$Res> {
  factory _$ProductSummaryCopyWith(
          _ProductSummary value, $Res Function(_ProductSummary) _then) =
      __$ProductSummaryCopyWithImpl;
  @override
  @useResult
  $Res call({String productName, int totalQty, int totalRevenue});
}

/// @nodoc
class __$ProductSummaryCopyWithImpl<$Res>
    implements _$ProductSummaryCopyWith<$Res> {
  __$ProductSummaryCopyWithImpl(this._self, this._then);

  final _ProductSummary _self;
  final $Res Function(_ProductSummary) _then;

  /// Create a copy of ProductSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? productName = null,
    Object? totalQty = null,
    Object? totalRevenue = null,
  }) {
    return _then(_ProductSummary(
      productName: null == productName
          ? _self.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      totalQty: null == totalQty
          ? _self.totalQty
          : totalQty // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _self.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
