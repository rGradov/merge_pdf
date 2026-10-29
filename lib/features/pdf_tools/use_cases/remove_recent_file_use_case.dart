import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Deletes one recent file and its stored PDF.
final class RemoveRecentFileUseCase implements BaseUseCase1<Empty, int> {
  /// Creates the use case bound to [_repository].
  const RemoveRecentFileUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<EmptyResult> call(int id) => _repository.removeRecent(id);
}
