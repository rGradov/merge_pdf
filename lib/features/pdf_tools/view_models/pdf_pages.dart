import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_pages.g.dart';

/// Async provider resolving the page count of the file at [path].
@riverpod
Future<Result<int>> pdfPages(Ref ref, String path) => getIt.get<PdfToolsRepository>().pageCount(path);
