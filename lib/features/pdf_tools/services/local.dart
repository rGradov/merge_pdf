import 'dart:io';
import 'dart:typed_data';
import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/services/services.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:pdf_manipulator/io.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';

/// [PdfEngineService] backed by the `pdf_manipulator` Rust engine.
@regular
@ruStore
@appGallery
@Singleton(as: PdfEngineService)
final class LocalPdfEngineService implements PdfEngineService {
  /// Clamps an inclusive page index to `[0, last]`.
  static int _clamp(int index, int last) => index < 0 ? 0 : (index > last ? last : index);

  @override
  Future<Result<int>> pageCount(String path) async {
    final pdf = Pdf();
    try {
      final doc = await pdf.open(FileSource(File(path)));
      try {
        return Result.success(doc.pageCount);
      } finally {
        await doc.dispose();
      }
    } on Exception catch (e) {
      return Result.failure<int>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<EmptyResult> merge(List<PdfFile> files, String outputPath) async {
    final pdf = Pdf();
    try {
      final sink = await FileSink.create(File(outputPath));
      try {
        await pdf.merge([for (final file in files) FileSource(File(file.path))], sink);
        return Result.success<Empty>(const Empty());
      } on Exception catch (e) {
        return Result.failure<Empty>(e);
      } finally {
        await sink.close();
      }
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<EmptyResult> split(
    String path,
    SplitMode mode,
    List<(int, int)> ranges,
    String Function(int index) outputPath,
  ) async {
    final pdf = Pdf();
    try {
      final source = FileSource(File(path));
      final doc = await pdf.open(source);
      final int total;
      try {
        total = doc.pageCount;
      } finally {
        await doc.dispose();
      }
      final batches = switch (mode) {
        SplitMode.everyPage => [for (var i = 0; i < total; i++) (i, i)],
        SplitMode.ranges => [for (final range in ranges) (_clamp(range.$1, total - 1), _clamp(range.$2, total - 1))],
      };
      for (var i = 0; i < batches.length; i++) {
        final (start, end) = batches[i];
        final sink = await FileSink.create(File(outputPath(i)));
        try {
          await pdf.extractPages(source, sink, pages: [for (var p = start; p <= end; p++) p]);
        } finally {
          await sink.close();
        }
      }
      return Result.success<Empty>(const Empty());
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<EmptyResult> rotate(String path, int degrees, String outputPath) async {
    final pdf = Pdf();
    try {
      final sink = await FileSink.create(File(outputPath));
      try {
        await pdf.rotateAllPages(FileSource(File(path)), sink, degrees: degrees);
        return Result.success<Empty>(const Empty());
      } on Exception catch (e) {
        return Result.failure<Empty>(e);
      } finally {
        await sink.close();
      }
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<EmptyResult> extractPages(String path, List<int> pages, String outputPath) async {
    final pdf = Pdf();
    try {
      final sink = await FileSink.create(File(outputPath));
      try {
        await pdf.extractPages(FileSource(File(path)), sink, pages: pages);
        return Result.success<Empty>(const Empty());
      } on Exception catch (e) {
        return Result.failure<Empty>(e);
      } finally {
        await sink.close();
      }
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<EmptyResult> rotatePages(String path, Map<int, int> pages, String outputPath) async {
    final pdf = Pdf();
    try {
      final sink = await FileSink.create(File(outputPath));
      try {
        await pdf.rotatePages(FileSource(File(path)), sink, pages: pages);
        return Result.success<Empty>(const Empty());
      } on Exception catch (e) {
        return Result.failure<Empty>(e);
      } finally {
        await sink.close();
      }
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    } finally {
      await pdf.dispose();
    }
  }

  @override
  Future<Result<Uint8List>> renderPage(String path, int pageIndex, {int maxDim = 800}) async {
    final pdf = Pdf();
    try {
      final doc = await pdf.open(FileSource(File(path)));
      try {
        final rendered = await doc
            .render(pages: PdfPages.single(pageIndex), size: PdfRenderSize.thumbnail(maxDim))
            .first;
        return Result.success(rendered.data);
      } on Exception catch (e) {
        return Result.failure<Uint8List>(e);
      } finally {
        await doc.dispose();
      }
    } on Exception catch (e) {
      return Result.failure<Uint8List>(e);
    } finally {
      await pdf.dispose();
    }
  }
}

/// ObjectBox-backed [RecentFilesService] registered for every store channel.
@regular
@ruStore
@appGallery
@Singleton(as: RecentFilesService)
final class LocalRecentFilesService implements RecentFilesService {
  /// Creates the service bound to [_storage].
  LocalRecentFilesService(this._storage);

  final StorageService _storage;

  @override
  Future<Result<List<RecentFile>>> all() async {
    try {
      final rows = _storage.store.box<RecentFileEntity>().getAll()
        ..sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
      return Result.success(rows.map((row) => row.map()).toList());
    } on Exception catch (e) {
      return Result.failure<List<RecentFile>>(e);
    }
  }

  @override
  Future<EmptyResult> put(RecentFile file) async {
    try {
      _storage.store.box<RecentFileEntity>().put(file.mapEntity());
      return Result.success<Empty>(const Empty());
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    }
  }

  @override
  Future<EmptyResult> remove(int id) async {
    try {
      _storage.store.box<RecentFileEntity>().remove(id);
      return Result.success<Empty>(const Empty());
    } on Exception catch (e) {
      return Result.failure<Empty>(e);
    }
  }
}
