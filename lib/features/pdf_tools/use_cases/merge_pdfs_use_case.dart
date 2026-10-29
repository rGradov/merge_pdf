import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Combines the picked files into one PDF.
final class MergePdfsUseCase implements BaseUseCase1<PdfResult, List<PdfFile>> {
  /// Creates the use case bound to [_repository].
  const MergePdfsUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<Result<PdfResult>> call(List<PdfFile> files) => _repository.merge(files);
}
