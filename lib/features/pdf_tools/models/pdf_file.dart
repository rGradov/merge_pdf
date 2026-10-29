import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_file.freezed.dart';

/// A user-picked source PDF.
@freezed
abstract class PdfFile with _$PdfFile {
  /// Creates a picked source file.
  const factory PdfFile({required String path, required String name, required int sizeBytes}) = _PdfFile;
}
