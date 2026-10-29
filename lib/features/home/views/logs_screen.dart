import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/core/widgets/widgets.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:merge_pdf/utils/utils.dart';

/// Debug screen showing everything captured by [AppLog].
final class LogsScreen extends StatelessWidget {
  /// Creates the logs screen.
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolAppBar(
            title: context.tr('settings.title') + ' · Logs',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.horizontalPadding),
              child: SelectableText(
                AppLog.instance.asText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.5, color: AppColors.text),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
