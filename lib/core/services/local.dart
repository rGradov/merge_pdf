import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/objectbox.g.dart';
import 'package:merge_pdf/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

/// ObjectBox-backed [StorageService] registered for every store channel.
@regular
@ruStore
@appGallery
@Singleton(as: StorageService)
final class LocalStorageService implements StorageService {
  Store? _store;

  @override
  Future<void> init() async {
    if (_store != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _store = Store(getObjectBoxModel(), directory: '${dir.path}/objectbox');
  }

  @override
  Store get store {
    final current = _store;
    if (current == null) {
      throw StateError('StorageService.init() must run before use');
    }
    return current;
  }
}

/// MethodChannel-backed [ShareService] registered for every store channel.
@regular
@ruStore
@appGallery
@Singleton(as: ShareService)
final class LocalShareService implements ShareService {
  static const MethodChannel _channel = MethodChannel('merge_pdf/share');

  @override
  Future<EmptyResult> shareFile(String path) async {
    try {
      await _channel.invokeMethod<void>('shareFile', <String, Object>{'path': path});
      return Result.success<Empty>(const Empty());
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    }
  }
}
