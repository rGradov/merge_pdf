import 'package:flutter/foundation.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/features/pdf_tools/repositories/repositories.dart';
import 'package:merge_pdf/global.dart';
import 'package:merge_pdf/utils/command.dart';
import 'package:merge_pdf/utils/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'split_vm.g.dart';

/// Screen state and actions for the split flow.
final class SplitVm {
  /// Selected source document.
  final ValueNotifier<PdfFile?> file = ValueNotifier(null);

  /// 0-based indices of the pages to keep.
  final ValueNotifier<Set<int>> selected = ValueNotifier({});

  /// Whether the unselected pages should also be saved as a second PDF.
  final ValueNotifier<bool> saveUnselected = ValueNotifier(false);

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

    final repo = getIt.get<PdfToolsRepository>();
    final results = <PdfResult>[];

    final selectedResult = await repo.extract(current, pages);
    switch (selectedResult) {
      case Failure(:final error):
        return Result.failure<List<PdfResult>>(error);
      case Success(:final value):
        results.add(value);
    }

    if (saveUnselected.value) {
      final total = (await repo.pageCount(current.path)).valueOrNull ?? 0;
      final selectedSet = selected.value;
      final rest = [for (var i = 0; i < total; i++) if (!selectedSet.contains(i)) i];
      if (rest.isNotEmpty) {
        final restResult = await repo.extract(current, rest);
        if (restResult case Success(:final value)) results.add(value);
      }
    }

    return Result.success(results);
  });

  /// Sets the selected document.
  void setFile(PdfFile? value) {
    if (value?.path != file.value?.path) selected.value = {};
    file.value = value;
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
