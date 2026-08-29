import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_cached_image.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';
import 'package:target_ace/core/shared/widgets/fade_wave_animation.dart';

class SubjectCard extends StatefulWidget {
  final String title;
  final String? description;
  final int practiced;
  final int total;
  final String? image;
  final bool isRefreshing;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    this.description,
    this.practiced = 0,
    this.total = 0,
    this.image,
    this.isRefreshing = false,
    required this.onTap,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard> {
  Widget? _buildLeadingImage() {
    if (widget.image == null || widget.image!.isEmpty) return null;

    final imgStr = widget.image!.trim();
    return CustomCachedImage(
      imageUrl: imgStr,
      width: 60,
      height: 74,
      borderRadius: 8.0,
      useShimmer: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final leading = _buildLeadingImage();
    const Color resolvedTextColor = AppColors.textPrimary;

    return CustomContainer(
      onTap: widget.onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: AppFonts.heading(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: resolvedTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.description != null && widget.description!.isNotEmpty) ...[
                  Text(
                    widget.description!,
                    style: AppFonts.body(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Builder(
                  builder: (context) {
                    Widget progressSection = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: widget.total > 0 ? widget.practiced / widget.total : 0.0,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.practiced} / ${widget.total} questions',
                          style: AppFonts.body(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );

                    if (widget.isRefreshing) {
                      return FadeWaveAnimation(child: progressSection);
                    }
                    return progressSection;
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}