import 'package:injectable/injectable.dart';

import 'package:merge_pdf/core/services/services.dart';
import 'package:merge_pdf/core/use_cases/use_cases.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Opens the platform share sheet for a produced file.
@injectable
final class SharePdfUseCase implements BaseUseCase1<Empty, PdfResult> {
  /// Creates the use case bound to [_share].
  const SharePdfUseCase(this._share);

  final ShareService _share;

  @override
  Future<EmptyResult> call(PdfResult result) => _share.shareFile(result.path);
}
