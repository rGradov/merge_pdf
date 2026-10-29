import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/features/pdf_tools/services/services.dart';
import 'package:merge_pdf/features/pdf_tools/use_cases/use_cases.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'split_vm.g.dart';

/// How the split screen groups the selected pages.
enum SplitSelectionMode {
  /// One output file per selected page.
  separate,

  /// One output file containing every selected page.
  extract,
}

/// Screen state and actions for the split flow.
final class SplitVm {
  /// Selected source document.
  final ValueNotifier<PdfFile?> file = ValueNotifier(null);

  /// Split grouping mode.
  final ValueNotifier<SplitSelectionMode> mode = ValueNotifier(SplitSelectionMode.separate);

  /// 0-based indices of the pages to keep.
  final ValueNotifier<Set<int>> selected = ValueNotifier({});

  String? _initializedFor;

  /// Runs the split action on the current state.
  late final Command0<List<PdfResult>> split = Command0(() async {
    final current = file.value;
    if (current == null) {
      return Result.failure<List<PdfResult>>(Exception('no_file'));
    }
    final pages = selected.value.toList()..sort();
    if (pages.isEmpty) {
      return Result.failure<List<PdfResult>>(Exception('no_file'));
    }
    if (mode.value == SplitSelectionMode.extract) {
      final result = await getIt.get<PdfToolsRepository>().extract(current, pages);
      return switch (result) {
        Success(:final value) => Result.success([value]),
        Failure(:final error) => Result.failure<List<PdfResult>>(error),
      };
    }
    final ranges = [for (final p in pages) (p, p)];
    return getIt.get<SplitPdfUseCase>().call(current, SplitMode.ranges, ranges);
  });

  /// Sets the selected document and resets the selection for a new file.
  void setFile(PdfFile? value) {
    if (value?.path != file.value?.path) _initializedFor = null;
    file.value = value;
  }

  /// Sets the split grouping mode.
  void setMode(SplitSelectionMode value) => mode.value = value;

  /// Selects every page of [path] once when the page count first resolves.
  void ensureInitialized(String path, int pageCount) {
    if (_initializedFor != path) {
      _initializedFor = path;
      selected.value = {for (var i = 0; i < pageCount; i++) i};
    }
  }

  /// Toggles a page in the selection.
  void toggle(int page) {
    final next = Set<int>.of(selected.value);
    if (!next.add(page)) next.remove(page);
    selected.value = next;
  }

  /// Clears the current selection.
  void clearSelection() => selected.value = {};
}

/// Provides the split screen view model.
@riverpod
SplitVm splitVm(Ref ref) => SplitVm();
