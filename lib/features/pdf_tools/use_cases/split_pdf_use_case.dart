import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Splits one document into several files.
final class SplitPdfUseCase implements BaseUseCase3<List<PdfResult>, PdfFile, SplitMode, List<(int, int)>> {
  /// Creates the use case bound to [_repository].
  const SplitPdfUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<Result<List<PdfResult>>> call(PdfFile file, SplitMode mode, List<(int, int)> ranges) =>
      _repository.split(file, mode, ranges);
}
