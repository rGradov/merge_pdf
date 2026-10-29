import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Rotates the selected pages of one document.
final class RotatePdfUseCase implements BaseUseCase3<PdfResult, PdfFile, int, List<int>> {
  /// Creates the use case bound to [_repository].
  const RotatePdfUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<Result<PdfResult>> call(PdfFile file, int degrees, List<int> pages) =>
      _repository.rotate(file, degrees, pages);
}
