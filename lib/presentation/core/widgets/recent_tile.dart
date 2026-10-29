import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:merge_pdf/features/pdf_tools/models/models.dart';
import 'package:merge_pdf/presentation/core/widgets/pdf_doc_badge.dart';
import 'package:merge_pdf/presentation/presentation.dart';

/// One row in the Recent section: doc badge, name, meta and an actions menu.
final class RecentTile extends StatelessWidget {
  /// Creates a recent file tile.
  const RecentTile({super.key, required this.name, required this.subtitle, required this.onTap, required this.onMore});

  /// File display name.
  final String name;

  /// Meta line, e.g. "12 pages · 4.2 MB · 2h ago".
  final String subtitle;

  /// Called when the tile body is tapped.
  final VoidCallback onTap;

  /// Called when the "more" button is tapped.
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: AppDimens.recentTileHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusCard)),
      child: Row(
        children: [
          const PdfDocBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMore,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Center(child: SvgPicture.asset('assets/icons/dots.svg', width: 3.3, height: 13.3)),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Builds the meta line of a [RecentFile] in the active locale.
String recentFileMeta(BuildContext context, RecentFile file) {
  final pages = context.tr('file.pages', args: ['${file.pages}']);
  final sizeMb = (file.sizeBytes / 1024 / 1024).toStringAsFixed(1);
  final size = context.tr('file.size', args: [sizeMb]);
  final when = _ago(context, file.createdAt);
  return '$pages · $size · $when';
}

String _ago(BuildContext context, DateTime createdAt) {
  final delta = DateTime.now().difference(createdAt);
  if (delta.inHours < 1) return context.tr('file.ago_hours', args: ['1']);
  if (delta.inHours < 24) {
    return context.tr('file.ago_hours', args: ['${delta.inHours}']);
  }
  if (delta.inDays < 2) return context.tr('file.yesterday');
  final local = createdAt.toLocal();
  final month = local.month < 10 ? '0${local.month}' : '${local.month}';
  final day = local.day < 10 ? '0${local.day}' : '${local.day}';
  return '$day.$month';
}
