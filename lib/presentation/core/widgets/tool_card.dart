import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// One toolbox entry (Merge / Split / Rotate) on the home screen.
final class ToolCard extends StatelessWidget {
  /// Creates a toolbox card.
  const ToolCard({super.key, required this.icon, required this.iconSize, required this.label, required this.onTap});

  /// Icon asset path.
  final String icon;

  /// Icon drawing size in logical pixels.
  final Size iconSize;

  /// Card label.
  final String label;

  /// Called when the card is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimens.toolCardHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(icon, width: iconSize.width, height: iconSize.height),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
            ),
          ],
        ),
      ),
    ),
  );
}
