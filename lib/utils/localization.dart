import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';

/// Renders [Exception] messages as localized strings.
///
/// Exceptions thrown across layers carry localization keys (`need_two_files`),
/// never user-facing sentences.
extension LocalizedException on Exception {
  /// Resolves the exception message against `error.<message>` in the active
  /// locale; falls back to `error.unknown` when the key is missing.
  String localized(BuildContext context) {
    final raw = toString().replaceFirst(RegExp('^Exception: '), '');
    final key = raw.startsWith('error.') ? raw : 'error.$raw';
    final translated = context.tr(key);
    return translated == key ? context.tr('error.unknown') : translated;
  }
}

/// Loads every locale from the single `assets/all.csv` file.
///
/// The first CSV row lists locale columns (`en,ru`); each following row is
/// `key,<en value>,<ru value>`. Fields may be quoted with double quotes.
final class AllCsvAssetLoader extends AssetLoader {
  /// Creates the loader that reads `assets/all.csv`.
  const AllCsvAssetLoader();

  static const String _csvAsset = 'assets/all.csv';

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    final raw = await rootBundle.loadString(_csvAsset);
    final rows = _parse(raw);
    if (rows.isEmpty) return const {};
    final header = rows.first;
    var index = header.indexOf(locale.languageCode);
    if (index < 0) index = header.indexOf('en');
    if (index < 0) return const {};
    return <String, dynamic>{
      for (final row in rows.skip(1))
        if (row.length > index) row.first: row[index],
    };
  }

  List<List<String>> _parse(String raw) {
    final result = <List<String>>[];
    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      result.add(_splitRow(trimmed));
    }
    return result;
  }

  List<String> _splitRow(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        quoted = !quoted;
      } else if (char == ',' && !quoted) {
        cells.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    cells.add(buffer.toString());
    return cells;
  }
}

/// Formats a byte count into a short, locale-aware size label
/// (e.g. `520 KB`, `1.1 MB`, `4.22 MB`).
String formatBytes(BuildContext context, int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb >= 1) {
    var text = mb.toStringAsFixed(2);
    if (text.contains('.')) {
      text = text
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return context.tr('file.size', namedArgs: {'n': text});
  }
  final kb = (bytes / 1024).round();
  return context.tr('file.sizeKb', namedArgs: {'n': '$kb'});
}
