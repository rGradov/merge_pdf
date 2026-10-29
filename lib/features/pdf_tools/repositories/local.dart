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
  Future<Result<PdfResult>> rotate(PdfFile file, int degrees) async {
    try {
      final now = DateTime.now();
      final name = 'rotated-${now.millisecondsSinceEpoch}.pdf';
      final path = await _outputPath(name);
      final written = await _engine.rotate(file.path, degrees, path);
      final error = written.errorOrNull;
      if (error != null) return Result.failure(error);
      final pages = await _countPages(path);
      final sizeBytes = File(path).lengthSync();
      final result = PdfResult(path: path, name: name, pages: pages, sizeBytes: sizeBytes, tool: ToolKind.rotate);
      await _record(_recent(result, now));
      return Result.success(result);
    } on Exception catch (e) {
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
