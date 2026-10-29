/// Fallible computation result that travels across layers without exceptions.
///
/// Services and repositories never throw; they return a [Result] instead.
sealed class Result<T> {
  const Result();

  /// Whether this result holds a value.
  bool get isSuccess => this is Success<T>;

  /// The wrapped error when this is a [Failure], otherwise `null`.
  Exception? get errorOrNull => switch (this) {
    Failure(:final error) => error,
    _ => null,
  };

  /// The wrapped value when this is a [Success], otherwise `null`.
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    _ => null,
  };

  /// Wraps [value] into [Success].
  static Result<T> success<T>(T value) => Success(value);

  /// Wraps [error] into [Failure].
  static Result<T> failure<T>(Exception error) => Failure(error);
}

/// Successful computation with a value.
final class Success<T> extends Result<T> {
  /// Creates the success result holding [value].
  const Success(this.value);

  /// The produced value.
  final T value;
}

/// Failed computation carrying a localization key.
final class Failure<T> extends Result<T> {
  /// Creates the failure result carrying [error].
  const Failure(this.error);

  /// The error whose message is a localization key.
  final Exception error;
}

/// Marker payload for actions that produce nothing.
final class Empty {
  /// Creates the empty payload.
  const Empty();
}

/// A [Result] for actions without a payload.
typedef EmptyResult = Result<Empty>;
