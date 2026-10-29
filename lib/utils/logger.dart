import 'dart:io';
import 'package:flutter/foundation.dart';

/// A single captured log line.
final class LogEntry {
  /// Creates a log line.
  const LogEntry({required this.time, required this.level, required this.message});

  /// When the entry was captured.
  final DateTime time;

  /// Level tag, e.g. INFO / WARN / ERROR.
  final String level;

  /// Human-readable message.
  final String message;

  @override
  String toString() => '[${_format(time)}] [$level] $message';

  static String _format(DateTime t) {
    String pad(int v, int n) => v.toString().padLeft(n, '0');
    return '${pad(t.hour, 2)}:${pad(t.minute, 2)}:${pad(t.second, 2)}.${pad(t.millisecond, 3)}';
  }
}

/// Process-wide logger: prints to console in debug builds and keeps a bounded
/// in-memory buffer that can be shown on a debugging screen.
final class AppLog {
  AppLog._();

  /// Shared instance.
  static final AppLog instance = AppLog._();

  static const int _maxEntries = 4000;

  final List<LogEntry> _entries = [];

  /// Captured entries, oldest first.
  List<LogEntry> get entries => List.unmodifiable(_entries);

  /// Captured entries joined into one plain-text dump.
  String get asText => _entries.map((e) => e.toString()).join('\n');

  /// Adds a line.
  void _add(String level, String message) {
    final entry = LogEntry(time: DateTime.now(), level: level, message: message);
    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
    if (kDebugMode) {
      debugPrint('[${LogEntry._format(entry.time)}] [$level] $message');
    }
  }

  /// Debug-level line.
  void debug(String message) => _add('DEBUG', message);

  /// Info-level line.
  void info(String message) => _add('INFO', message);

  /// Warning-level line.
  void warn(String message) => _add('WARN', message);

  /// Error-level line.
  void error(String message, [Object? error, StackTrace? stack]) {
    final buffer = StringBuffer(message);
    if (error != null) buffer.write('\n$error');
    if (stack != null) buffer.write('\n$stack');
    _add('ERROR', buffer.toString());
  }

  /// Logs device / OS facts; best called once at startup.
  void logDeviceInfo() {
    try {
      info('device.os=${Platform.operatingSystem}');
      info('device.osVersion=${Platform.operatingSystemVersion}');
      info('device.dartVm=${Platform.version}');
      info('device.processors=${Platform.numberOfProcessors}');
      info('device.host=${Platform.localHostname}');
      info('build.isDebug=$kDebugMode isProfile=$kProfileMode isRelease=$kReleaseMode');
    } catch (error) {
      warn('Could not read device info: $error');
    }
  }
}
