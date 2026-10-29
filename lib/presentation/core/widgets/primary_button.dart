import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// The main red pill button (56px, radius 9999) with an optional leading icon.
final class PrimaryButton extends StatelessWidget {
  /// Creates the red pill button.
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.iconAsset,
    this.enabled = true,
    this.loading = false,
  });

  /// Button text.
  final String label;

  /// Called when the button is tapped.
  final VoidCallback onTap;

  /// Optional leading icon asset path.
  final String? iconAsset;

  /// Whether the button accepts taps.
  final bool enabled;

  /// Whether a progress indicator replaces the label.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final icon = iconAsset;
    return GestureDetector(
      onTap: enabled && !loading ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: AppDimens.ctaHeight,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9999)),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[SvgPicture.asset(icon, width: 12, height: 12), const SizedBox(width: 9)],
                      Text(
                        label,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
