import 'package:file_picker/file_picker.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';

/// Picks PDF files from the system picker.
///
/// Returns an empty list when the user cancels.
Future<List<PdfFile>> pickPdfFiles({bool allowMultiple = false}) async {
  final files = <PlatformFile>[];
  if (allowMultiple) {
    files.addAll(await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']));
  } else {
    final single = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (single != null) files.add(single);
  }
  return [
    for (final picked in files)
      if (picked.path != null) PdfFile(path: picked.path!, name: picked.name, sizeBytes: picked.lengthSync() ?? 0),
  ];
}
