import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:merge_pdf/features/pdf_tools/models/tool_kind.dart';

part 'pdf_result.freezed.dart';

/// A produced PDF file ready to share or open.
@freezed
abstract class PdfResult with _$PdfResult {
  /// Creates a produced output file.
  const factory PdfResult({
    required String path,
    required String name,
    required int pages,
    required int sizeBytes,
    required ToolKind tool,
  }) = _PdfResult;
}
