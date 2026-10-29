import 'package:merge_pdf/utils/result.dart';

/// A parameterless meaningful action.
abstract interface class BaseUseCase0<O> {
  /// Runs the action.
  Future<Result<O>> call();
}

/// A one-argument meaningful action.
abstract interface class BaseUseCase1<O, A> {
  /// Runs the action with [arg].
  Future<Result<O>> call(A arg);
}

/// A two-argument meaningful action.
abstract interface class BaseUseCase2<O, A, B> {
  /// Runs the action with [a] and [b].
  Future<Result<O>> call(A a, B b);
}

/// A three-argument meaningful action.
abstract interface class BaseUseCase3<O, A, B, C> {
  /// Runs the action with [a], [b] and [c].
  Future<Result<O>> call(A a, B b, C c);
}
