import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

/// Composes the PDF engine and the recents store into domain operations.
@regular
@ruStore
@appGallery
@Injectable(as: PdfToolsRepository)
final class LocalPdfToolsRepository implements PdfToolsRepository {
  /// Creates the repository composing [_engine] and [_recents].
  LocalPdfToolsRepository(this._engine, this._recents);

  final PdfEngineService _engine;
  final RecentFilesService _recents;

  static int _seq = 0;

  Future<String> _outputDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final outputs = Directory('${dir.path}/outputs');
    await outputs.create(recursive: true);
    return outputs.path;
  }

  Future<String> _outputPath(String baseName) async => '${await _outputDir()}/$baseName';

  Future<EmptyResult> _record(RecentFile file) => _recents.put(file);

  Future<int> _countPages(String path) async {
    final count = await _engine.pageCount(path);
    return switch (count) {
      Success(:final value) => value,
      Failure() => 0,
    };
  }

  @override
  Future<Result<int>> pageCount(String path) => _engine.pageCount(path);

  @override
  Future<Result<PdfResult>> merge(List<PdfFile> files) async {
    try {
      final now = DateTime.now();
      final name = 'merged-${now.millisecondsSinceEpoch}.pdf';
      final path = await _outputPath(name);
      final written = await _engine.merge(files, path);
      final error = written.errorOrNull;
      if (error != null) return Result.failure(error);
      final pages = await _countPages(path);
      final sizeBytes = File(path).lengthSync();
      final result = PdfResult(path: path, name: name, pages: pages, sizeBytes: sizeBytes, tool: ToolKind.merge);
      await _record(_recent(result, now));
      return Result.success(result);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<PdfResult>> mergeSelected(
    List<PdfFile> files,
    Map<String, (int, int)> pageRanges,
  ) async {
    try {
      final now = DateTime.now();
      AppLog.instance.info(
        'merge.start inputs=${files.map((f) => '${f.name}|${f.sizeBytes}B|${f.path}').join(', ')}',
      );
      final tempDir = Directory('${await _outputDir()}/tmp');
      await tempDir.create(recursive: true);

      final toMerge = <PdfFile>[];
      final temps = <String>[];
      for (final file in files) {
        final range = pageRanges[file.path];
        if (range == null) {
          toMerge.add(file);
          continue;
        }
        final total = await _countPages(file.path);
        if (total <= 0) {
          toMerge.add(file);
          continue;
        }
        final start = range.$1.clamp(0, total - 1);
        final end = range.$2.clamp(0, total - 1);
        if (start <= 0 && end >= total - 1) {
          toMerge.add(file);
          continue;
        }
        final pages = [for (var p = start; p <= end; p++) p];
        final tempPath = '${tempDir.path}/trim-${now.millisecondsSinceEpoch}-${toMerge.length}.pdf';
        final written = await _engine.extractPages(file.path, pages, tempPath);
        if (written.errorOrNull case final error?) return Result.failure(error);
        temps.add(tempPath);
        toMerge.add(PdfFile(path: tempPath, name: file.name, sizeBytes: File(tempPath).lengthSync()));
      }

      final name = _mergedName(files);
      final path = await _outputPath(name);
      final written = await _engine.merge(toMerge, path);
      final error = written.errorOrNull;
      if (error != null) return Result.failure(error);

      for (final temp in temps) {
        try {
          File(temp).deleteSync();
        } on Exception {
          // Best-effort cleanup of temporary extracted files.
        }
      }

      final pages = await _countPages(path);
      final sizeBytes = File(path).lengthSync();
      final result = PdfResult(path: path, name: name, pages: pages, sizeBytes: sizeBytes, tool: ToolKind.merge);
      AppLog.instance.info('merge.done output=$path pages=$pages size=${sizeBytes}B');
      await _record(_recent(result, now));
      return Result.success(result);
    } on Exception catch (e) {
      AppLog.instance.error('merge.failed', e);
      return Result.failure(e);
    }
  }

  String _mergedName(List<PdfFile> files) {
    final first = files.first.name;
    final base = first.toLowerCase().endsWith('.pdf') ? first.substring(0, first.length - 4) : first;
    if (files.length == 1) return '$base.pdf';
    return '$base + ${files.length - 1} more.pdf';
  }

  @override
  Future<Result<PdfResult>> extract(PdfFile file, List<int> pages) async {
    try {
      final now = DateTime.now();
      AppLog.instance.info('split.extract.start input=${file.path} pages=${pages.length} pagesList=$pages');
      final name = 'extract-${now.millisecondsSinceEpoch}-${_seq++}.pdf';
      final path = await _outputPath(name);
      final written = await _engine.extractPages(file.path, pages, path);
      final error = written.errorOrNull;
      if (error != null) return Result.failure(error);
      final sizeBytes = File(path).lengthSync();
      final result = PdfResult(
        path: path,
        name: name,
        pages: pages.length,
        sizeBytes: sizeBytes,
        tool: ToolKind.split,
      );
      AppLog.instance.info('split.extract.done output=$path pages=${pages.length} size=${sizeBytes}B');
      await _record(_recent(result, now));
      return Result.success(result);
    } on Exception catch (e) {
      AppLog.instance.error('split.extract.failed', e);
      return Result.failure(e);
    }
  }

  @override
  Future<Result<List<PdfResult>>> split(PdfFile file, SplitMode mode, List<(int, int)> ranges) async {
    try {
      final now = DateTime.now();
      final stamp = now.millisecondsSinceEpoch;
      final dir = await _outputDir();
      final outputPaths = <String>[];
      final written = await _engine.split(file.path, mode, ranges, (index) {
        final path = '$dir/$stamp-split-$index.pdf';
        outputPaths.add(path);
        return path;
      });
      if (written.errorOrNull case final error?) return Result.failure(error);
      final results = <PdfResult>[];
      for (var i = 0; i < outputPaths.length; i++) {
        final path = outputPaths[i];
        final pages = await _countPages(path);
        final sizeBytes = File(path).lengthSync();
        final result = PdfResult(
          path: path,
          name: path.split('/').last,
          pages: pages,
          sizeBytes: sizeBytes,
          tool: ToolKind.split,
        );
        results.add(result);
        await _record(_recent(result, now));
      }
      return Result.success(results);
    } on Exception catch (e) {
      return Result.failure(e);
    }
  }

  @override
  Future<Result<PdfResult>> rotate(PdfFile file, int degrees, List<int> pages) async {
    try {
      final now = DateTime.now();
      AppLog.instance.info('rotate.start input=${file.path} degrees=$degrees pages=${pages.length}');
      final name = 'rotated-${now.millisecondsSinceEpoch}.pdf';
      final path = await _outputPath(name);
      final written = await _engine.rotatePages(file.path, {for (final p in pages) p: degrees}, path);
      final error = written.errorOrNull;
      if (error != null) return Result.failure(error);
      final totalPages = await _countPages(path);
      final sizeBytes = File(path).lengthSync();
      final result = PdfResult(
        path: path,
        name: name,
        pages: totalPages,
        sizeBytes: sizeBytes,
        tool: ToolKind.rotate,
      );
      AppLog.instance.info('rotate.done output=$path pages=$totalPages size=${sizeBytes}B');
      await _record(_recent(result, now));
      return Result.success(result);
    } on Exception catch (e) {
      AppLog.instance.error('rotate.failed', e);
      return Result.failure(e);
    }
  }

  RecentFile _recent(PdfResult result, DateTime createdAt) => RecentFile(
    id: 0,
    name: result.name,
    path: result.path,
    pages: result.pages,
    sizeBytes: result.sizeBytes,
    createdAt: createdAt,
    tool: result.tool,
  );

  @override
  Future<Result<DataState<List<RecentFile>>>> recents() async {
    final result = await _recents.all();
    return switch (result) {
      Success(:final value) => Result.success(
        value.isEmpty ? const NoData<List<RecentFile>>() : HasData<List<RecentFile>>(value),
      ),
      Failure(:final error) => Result.failure(error),
    };
  }

  @override
  Future<EmptyResult> removeRecent(int id) async {
    final rows = await _recents.all();
    if (rows case Success(:final value)) {
      for (final file in value.where((row) => row.id == id)) {
        try {
          final stored = File(file.path);
          if (stored.existsSync()) stored.deleteSync();
        } on Exception {
          // The row is removed regardless of a filesystem hiccup.
        }
      }
    }
    return await _recents.remove(id);
  }

  @override
  Future<EmptyResult> clearAll() async {
    final rows = await _recents.all();
    if (rows case Success(:final value)) {
      for (final file in value) {
        try {
          final stored = File(file.path);
          if (stored.existsSync()) stored.deleteSync();
        } on Exception {
          // Keep clearing the remaining rows.
        }
        final removed = await _recents.remove(file.id);
        final error = removed.errorOrNull;
        if (error != null) return Result.failure<Empty>(error);
      }
    }
    return Result.success<Empty>(const Empty());
  }
}
