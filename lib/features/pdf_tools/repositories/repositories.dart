import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Feature data gateway in domain terms.
abstract interface class PdfToolsRepository {
  /// Returns the number of pages of the file at [path].
  Future<Result<int>> pageCount(String path);

  /// Combines [files] into a single output and records it as recent.
  Future<Result<PdfResult>> merge(List<PdfFile> files);

  /// Combines [files], trimming each file to its inclusive 0-based page range
  /// in [pageRanges] (keyed by `path`), then records the result as recent.
  Future<Result<PdfResult>> mergeSelected(List<PdfFile> files, Map<String, (int, int)> pageRanges);

  /// Splits a document according to [mode] and [ranges] (0-based inclusive).
  Future<Result<List<PdfResult>>> split(PdfFile file, SplitMode mode, List<(int, int)> ranges);

  /// Extracts the 0-based [pages] into a single document and records it.
  Future<Result<PdfResult>> extract(PdfFile file, List<int> pages);

  /// Rotates only [pages] of [file] by [degrees] and records the result.
  Future<Result<PdfResult>> rotate(PdfFile file, int degrees, List<int> pages);

  /// Recent files, newest first.
  Future<Result<DataState<List<RecentFile>>>> recents();

  /// Deletes a recent file row and its stored file.
  Future<EmptyResult> removeRecent(int id);

  /// Removes every stored output file and its row.
  Future<EmptyResult> clearAll();
}
