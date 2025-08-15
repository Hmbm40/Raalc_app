// lib/network/apiResult.dart
import 'package:meta/meta.dart';

/// A tiny, zero-dependency result type that carries either:
///  - Ok(value)
///  - Err(error[, stackTrace])
///
/// Usage:
///   final res = await api.register(...);
///   res.when(
///     ok: (data) { ... },
///     err: (e, st) { ... },
///   );
///
/// Construction:
///   return ApiResult.ok(value);
///   return ApiResult.err(error, stackTrace);
@immutable
sealed class ApiResult<T> {
  const ApiResult();

  /// Success case
  const factory ApiResult.ok(T value) = Ok<T>;

  /// Error case
  const factory ApiResult.err(Object error, [StackTrace? stackTrace]) = Err<T>;

  /// True if this is Ok
  bool get isOk => this is Ok<T>;

  /// True if this is Err
  bool get isErr => this is Err<T>;

  /// Get value or null (Ok only)
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;

  /// Get error or null (Err only)
  Object? get errorOrNull => this is Err<T> ? (this as Err<T>).error : null;

  /// Get stackTrace or null (Err only)
  StackTrace? get stackTrace =>
      this is Err<T> ? (this as Err<T>).stackTrace : null;

  /// Pattern-match style API.
  R when<R>({
    required R Function(T data) ok,
    required R Function(Object error, StackTrace? stack) err,
  }) {
    final self = this;
    if (self is Ok<T>) return ok(self.value);
    final e = self as Err<T>;
    return err(e.error, e.stackTrace);
  }

  /// Transform Ok(value) -> Ok(mapper(value)); Err flows through unchanged.
  ApiResult<U> map<U>(U Function(T data) mapper) {
    final self = this;
    if (self is Ok<T>) return ApiResult.ok(mapper(self.value));
    final e = self as Err<T>;
    return ApiResult.err(e.error, e.stackTrace);
  }

  /// Transform Err(error) -> Err(mapper(error)); Ok flows through unchanged.
  ApiResult<T> mapError(Object Function(Object error) mapper) {
    final self = this;
    if (self is Err<T>) return ApiResult.err(mapper(self.error), self.stackTrace);
    return this;
  }

  /// Unwrap with a default.
  T unwrapOr(T fallback) => when(ok: (v) => v, err: (_, __) => fallback);

  /// Unwrap with a lazy default.
  T unwrapOrElse(T Function(Object error) fallback) =>
      when(ok: (v) => v, err: (e, __) => fallback(e));

  @override
  String toString() => when(
        ok: (v) => 'Ok($v)',
        err: (e, st) => 'Err($e${st != null ? ', $st' : ''})',
      );
}

@immutable
final class Ok<T> extends ApiResult<T> {
  const Ok(this.value);
  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ok<T> && runtimeType == other.runtimeType && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

@immutable
final class Err<T> extends ApiResult<T> {
  const Err(this.error, [this.stackTrace]);
  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Err<T> &&
          runtimeType == other.runtimeType &&
          other.error == error &&
          other.stackTrace == stackTrace;

  @override
  int get hashCode => Object.hash(runtimeType, error, stackTrace);
}
