import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rotate_vm.g.dart';

/// Rotation direction of the selected pages.
enum RotateDirection {
  /// 90° clockwise.
  clockwise,

  /// 90° counter-clockwise.
  counterClockwise,
}

/// Screen state and actions for the rotate flow.
final class RotateVm {
  /// Selected source document.
  final ValueNotifier<PdfFile?> file = ValueNotifier(null);

  /// Rotation direction.
  final ValueNotifier<RotateDirection> direction = ValueNotifier(RotateDirection.clockwise);

  /// 0-based indices of the pages to rotate.
  final ValueNotifier<Set<int>> selected = ValueNotifier({});

  /// Effective rotation degrees: clockwise is 90, counter-clockwise is 270.
  int get degrees => direction.value == RotateDirection.clockwise ? 90 : 270;

  /// Runs the rotate action on the current state.
  late final Command0<PdfResult> rotate = Command0(() async {
    final current = file.value;
    if (current == null) {
      return Result.failure<PdfResult>(Exception('no_file'));
    }
    final pages = selected.value.toList()..sort();
    if (pages.isEmpty) {
      return Result.failure<PdfResult>(Exception('no_file'));
    }
    return getIt.get<RotatePdfUseCase>().call(current, degrees, pages);
  });

  /// Sets the selected document and resets the selection for a new file.
  void setFile(PdfFile? value) {
    if (value?.path != file.value?.path) selected.value = {};
    file.value = value;
  }

  /// Sets the rotation direction.
  void setDirection(RotateDirection value) => direction.value = value;

  /// Toggles a page in the selection.
  void toggle(int page) {
    final next = Set<int>.of(selected.value);
    if (!next.add(page)) next.remove(page);
    selected.value = next;
  }

  /// Clears the current selection.
  void clearSelection() => selected.value = {};
}

/// Provides the rotate screen view model.
@riverpod
RotateVm rotateVm(Ref ref) => RotateVm();
