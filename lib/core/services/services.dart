import 'package:merge_pdf/utils/utils.dart';
import 'package:objectbox/objectbox.dart';

/// Owns the ObjectBox store of the whole app.
abstract interface class StorageService {
  /// Opens the store; safe to call once per process.
  Future<void> init();

  /// The opened ObjectBox [Store].
  Store get store;
}

/// Shares a local file through the platform share sheet.
abstract interface class ShareService {
  /// Opens the system share dialog for the file at [path].
  Future<EmptyResult> shareFile(String path);
}
