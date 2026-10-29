import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// Screen header matching the design: 28px semibold title and a
/// settings gear on the right.
final class MainAppBar extends StatelessWidget {
  /// Creates the header bar.
  const MainAppBar({super.key, required this.title, required this.onSettings});

  /// Page title, e.g. the localized app name.
  final String title;

  /// Called when the settings gear is tapped.
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                letterSpacing: -0.6,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSettings,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(child: SvgPicture.asset('assets/icons/settings.svg', width: 20, height: 20)),
            ),
          ),
        ],
      ),
    ),
  );
}
