import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rotate_vm.g.dart';

/// Screen state and actions for the rotate flow.
final class RotateVm {
  /// Selected source document.
  final ValueNotifier<PdfFile?> file = ValueNotifier(null);

  /// Rotation angle in degrees (90, 180 or 270).
  final ValueNotifier<int> angle = ValueNotifier(90);

  /// Runs the rotate action on the current state.
  late final Command0<PdfResult> rotate = Command0(() {
    final current = file.value;
    if (current == null) {
      return Future.value(Result.failure<PdfResult>(Exception('no_file')));
    }
    return getIt.get<RotatePdfUseCase>().call(current, angle.value);
  });

  /// Sets the selected document.
  void setFile(PdfFile? value) => file.value = value;

  /// Sets the rotation angle.
  void setAngle(int value) => angle.value = value;
}

/// Provides the rotate screen view model.
@riverpod
RotateVm rotateVm(Ref ref) => RotateVm();
