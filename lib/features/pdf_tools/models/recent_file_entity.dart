import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox row backing [RecentFile].
@Entity()
class RecentFileEntity {
  /// Constructor used by the mapper.
  RecentFileEntity({
    required this.name,
    required this.path,
    required this.pages,
    required this.sizeBytes,
    required this.createdAtMillis,
    required this.tool,
  });

  /// Row id assigned by ObjectBox.
  @Id()
  int id = 0;

  /// File display name.
  final String name;

  /// Absolute path to the stored file.
  final String path;

  /// Number of pages in the file.
  final int pages;

  /// File size in bytes.
  final int sizeBytes;

  /// Creation time as milliseconds since epoch.
  final int createdAtMillis;

  /// The tool that produced the file (`ToolKind.name`).
  final String tool;
}

/// Maps [RecentFileEntity] rows to domain models.
extension RecentFileEntityMapper on RecentFileEntity {
  /// Converts this row into its domain counterpart.
  RecentFile map() => RecentFile(
    id: id,
    name: name,
    path: path,
    pages: pages,
    sizeBytes: sizeBytes,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    tool: ToolKind.values.firstWhere((kind) => kind.name == tool, orElse: () => ToolKind.merge),
  );
}

/// Maps domain models to [RecentFileEntity] rows.
extension RecentFileMapper on RecentFile {
  /// Converts this model into a persistable row.
  RecentFileEntity mapEntity() => RecentFileEntity(
    name: name,
    path: path,
    pages: pages,
    sizeBytes: sizeBytes,
    createdAtMillis: createdAt.millisecondsSinceEpoch,
    tool: tool.name,
  );
}
