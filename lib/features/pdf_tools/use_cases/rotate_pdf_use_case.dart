import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Rotates every page of one document.
final class RotatePdfUseCase implements BaseUseCase2<PdfResult, PdfFile, int> {
  /// Creates the use case bound to [_repository].
  const RotatePdfUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<Result<PdfResult>> call(PdfFile file, int degrees) => _repository.rotate(file, degrees);
}
