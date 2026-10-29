import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'split_vm.g.dart';

/// Screen state and actions for the split flow.
final class SplitVm {
  /// Selected source document.
  final ValueNotifier<PdfFile?> file = ValueNotifier(null);

  /// Split strategy.
  final ValueNotifier<SplitMode> mode = ValueNotifier(SplitMode.everyPage);

  /// Raw ranges input for [SplitMode.ranges].
  final ValueNotifier<String> rangesText = ValueNotifier('');

  /// Runs the split action on the current state.
  late final Command0<List<PdfResult>> split = Command0(() {
    final current = file.value;
    if (current == null) {
      return Future.value(Result.failure<List<PdfResult>>(Exception('no_file')));
    }
    final ranges = _parseRanges(rangesText.value);
    if (mode.value == SplitMode.ranges && ranges == null) {
      return Future.value(Result.failure<List<PdfResult>>(Exception('bad_ranges')));
    }
    return getIt.get<SplitPdfUseCase>().call(current, mode.value, ranges ?? const []);
  });

  /// Sets the selected document.
  void setFile(PdfFile? value) => file.value = value;

  /// Sets the split strategy.
  void setMode(SplitMode value) => mode.value = value;

  /// Sets the raw ranges input.
  void setRanges(String value) => rangesText.value = value;

  List<(int, int)>? _parseRanges(String raw) {
    final parts = raw.split(',').map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final result = <(int, int)>[];
    for (final part in parts) {
      final sides = part.split('-');
      final start = int.tryParse(sides.first.trim());
      if (start == null || start < 1) return null;
      if (sides.length == 1) {
        result.add((start - 1, start - 1));
        continue;
      }
      final end = int.tryParse(sides.last.trim());
      if (end == null || end < start) return null;
      result.add((start - 1, end - 1));
    }
    return result;
  }
}

/// Provides the split screen view model.
@riverpod
SplitVm splitVm(Ref ref) => SplitVm();
