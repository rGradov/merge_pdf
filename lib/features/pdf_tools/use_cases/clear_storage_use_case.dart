import 'package:injectable/injectable.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/utils/result.dart';

@injectable
/// Removes every stored output file and its row.
final class ClearStorageUseCase implements BaseUseCase0<Empty> {
  /// Creates the use case bound to [_repository].
  const ClearStorageUseCase(this._repository);

  final PdfToolsRepository _repository;

  @override
  Future<EmptyResult> call() => _repository.clearAll();
}
