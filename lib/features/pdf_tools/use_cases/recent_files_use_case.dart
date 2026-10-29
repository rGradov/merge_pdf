import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/utils.dart';

@injectable
/// Loads the recent files list for the home screen.
final class RecentFilesUseCase implements BaseUseCase0<DataState<List<RecentFile>>> {
  /// Creates the use case bound to [_repository].
  const RecentFilesUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<Result<DataState<List<RecentFile>>>> call() => _repository.recents();
}
