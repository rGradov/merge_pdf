import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Feature data gateway in domain terms.
abstract interface class PdfToolsRepository {
  /// Returns the number of pages of the file at [path].
  Future<Result<int>> pageCount(String path);

  /// Combines [files] into a single output and records it as recent.
  Future<Result<PdfResult>> merge(List<PdfFile> files);

  /// Splits a document according to [mode] and [ranges] (0-based inclusive).
  Future<Result<List<PdfResult>>> split(PdfFile file, SplitMode mode, List<(int, int)> ranges);

  /// Rotates every page of [file] by [degrees] and records the result.
  Future<Result<PdfResult>> rotate(PdfFile file, int degrees);

  /// Recent files, newest first.
  Future<Result<DataState<List<RecentFile>>>> recents();

  /// Deletes a recent file row and its stored file.
  Future<EmptyResult> removeRecent(int id);

  /// Removes every stored output file and its row.
  Future<EmptyResult> clearAll();
}
