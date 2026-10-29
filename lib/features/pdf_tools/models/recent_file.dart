import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:merge_pdf/features/pdf_tools/models/tool_kind.dart';

part 'recent_file.freezed.dart';

/// A recently produced file shown on the home screen.
@freezed
abstract class RecentFile with _$RecentFile {
  /// Creates a recently produced file.
  const factory RecentFile({
    required int id,
    required String name,
    required String path,
    required int pages,
    required int sizeBytes,
    required DateTime createdAt,
    required ToolKind tool,
  }) = _RecentFile;
}
