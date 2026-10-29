import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recent_files.g.dart';

/// Async provider of the recent files list, newest first.
@riverpod
Future<Result<DataState<List<RecentFile>>>> recentFiles(Ref ref) => getIt.get<RecentFilesUseCase>().call();
