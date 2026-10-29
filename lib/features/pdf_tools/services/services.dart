import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/utils/result.dart';

/// Split strategies for one input document.
enum SplitMode {
  /// One output file per page.
  everyPage,

  /// One output file per requested range.
  ranges,
}

/// Low-level PDF engine: merge, split, rotate and metadata.
abstract interface class PdfEngineService {
  /// Returns the number of pages of the file at [path].
  Future<Result<int>> pageCount(String path);

  /// Merges [files] in order into one document stored at [outputPath].
  Future<EmptyResult> merge(List<PdfFile> files, String outputPath);

  /// Splits the document at [path].
  ///
  /// [ranges] holds 0-based inclusive page-index pairs; every batch is written
  /// to the path produced by [outputPath] for its index.
  Future<EmptyResult> split(
    String path,
    SplitMode mode,
    List<(int, int)> ranges,
    String Function(int index) outputPath,
  );

  /// Rotates every page by [degrees] (90, 180 or 270).
  Future<EmptyResult> rotate(String path, int degrees, String outputPath);

  /// Extracts the 0-based [pages] (in order) into one document at [outputPath].
  Future<EmptyResult> extractPages(String path, List<int> pages, String outputPath);

  /// Rotates only the pages in [pages] (0-based index → degrees) and writes the
  /// full document to [outputPath].
  Future<EmptyResult> rotatePages(String path, Map<int, int> pages, String outputPath);
}

/// Persistence of the recent files list.
abstract interface class RecentFilesService {
  /// Reads all rows, newest first.
  Future<Result<List<RecentFile>>> all();

  /// Inserts or updates a row.
  Future<EmptyResult> put(RecentFile file);

  /// Removes a row by id.
  Future<EmptyResult> remove(int id);
}
