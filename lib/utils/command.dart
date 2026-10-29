import 'package:flutter/foundation.dart';
import 'package:merge_pdf/utils/result.dart';

/// Runs a single-argument use case and exposes its running/error state.
final class Command1<O, A> {
  /// Creates the command wrapping [_action].
  Command1(this._action);

  final Future<Result<O>> Function(A arg) _action;

  /// Emits `true` while the action is in flight.
  final ValueNotifier<bool> isRunning = ValueNotifier(false);

  /// Holds the latest failure, if any.
  final ValueNotifier<Exception?> error = ValueNotifier(null);

  /// Executes the action, updating [isRunning] and [error] along the way.
  Future<Result<O>> call(A arg) async {
    isRunning.value = true;
    error.value = null;
    try {
      final result = await _action(arg);
      if (result case Failure(:final error)) {
        this.error.value = error;
      }
      return result;
    } on Exception catch (e) {
      error.value = e;
      return Result.failure(e);
    } finally {
      isRunning.value = false;
    }
  }
}

/// Runs a zero-argument use case and exposes its running/error state.
final class Command0<O> {
  /// Creates the command wrapping [_action].
  Command0(this._action);

  final Future<Result<O>> Function() _action;

  /// Emits `true` while the action is in flight.
  final ValueNotifier<bool> isRunning = ValueNotifier(false);

  /// Holds the latest failure, if any.
  final ValueNotifier<Exception?> error = ValueNotifier(null);

  /// Executes the action, updating [isRunning] and [error] along the way.
  Future<Result<O>> call() async {
    isRunning.value = true;
    error.value = null;
    try {
      final result = await _action();
      if (result case Failure(:final error)) {
        this.error.value = error;
      }
      return result;
    } on Exception catch (e) {
      error.value = e;
      return Result.failure(e);
    } finally {
      isRunning.value = false;
    }
  }
}
