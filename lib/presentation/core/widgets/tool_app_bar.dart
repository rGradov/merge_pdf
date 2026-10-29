import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// Header used by tool and settings screens: a back button, a title and an
/// optional trailing action cluster.
final class ToolAppBar extends StatelessWidget {
  /// Creates a tool header.
  const ToolAppBar({
    super.key,
    required this.title,
    required this.onBack,
    this.titleSize = 18,
    this.trailing,
  });

  /// Page title.
  final String title;

  /// Called when the back button is tapped.
  final VoidCallback onBack;

  /// Title font size (the design uses 18px for tool pages, 28px for Merge).
  final double titleSize;

  /// Optional widgets shown on the right, e.g. a Clear / Reset action.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.horizontalPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(Icons.arrow_back_ios, size: 20, color: AppColors.text),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                letterSpacing: titleSize > 20 ? -0.6 : -0.3,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    ),
  );
}

/// Red circular badge used as the trailing accent of tool headers.
final class ToolAccentDot extends StatelessWidget {
  /// Creates the red accent dot.
  const ToolAccentDot({super.key, required this.icon, this.onTap});

  /// Icon drawn inside the dot.
  final IconData icon;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: Center(child: Icon(icon, size: 16, color: AppColors.white)),
    ),
  );
}

/// Plain text header action, e.g. "Clear" / "Reset".
final class ToolTextAction extends StatelessWidget {
  /// Creates a text action.
  const ToolTextAction({super.key, required this.label, required this.onTap});

  /// Action label.
  final String label;

  /// Called when tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    ),
  );
}
