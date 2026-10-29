import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/core/navigation/navigation.dart';
import 'package:merge_pdf/presentation/presentation.dart';
import 'package:sizer/sizer.dart';

/// Root widget: localization, sizer and the typed router.
final class MergePdfApp extends StatelessWidget {
  /// Creates the root widget.
  const MergePdfApp({super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: Sizer(
      builder: (context, orientation, deviceType) => MaterialApp.router(
        title: 'Merge PDF',
        theme: appTheme(),
        locale: context.locale,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        routerConfig: appRouter,
      ),
    ),
  );
}
