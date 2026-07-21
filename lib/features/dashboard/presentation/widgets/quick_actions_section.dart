import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/features/battle/presentation/pages/subjects_page.dart';
import 'package:target_ace/features/profile/presentation/pages/profile_page.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  label: "Subject Practice",
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, SubjectsPage.route()),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _QuickActionItem(
                  icon: HugeIcons.strokeRoundedStarAward02,
                  label: "Leaderboard",
                  color: AppColors.warning,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Leaderboard will be updated after the match.")),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: HugeIcons.strokeRoundedDiamond02,
                  label: "Subscription",
                  color: AppColors.info,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Subscription Paywall coming soon.")),
                    );
                  },
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _QuickActionItem(
                  icon: HugeIcons.strokeRoundedUser03,
                  label: "My Profile",
                  color: AppColors.accentDark,
                  onTap: () => Navigator.push(context, ProfilePage.route()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatefulWidget {
  final List<List<dynamic>> icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionItem> createState() => _QuickActionItemState();
}

class _QuickActionItemState extends State<_QuickActionItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _pressed
                ? widget.color.withValues(alpha: 0.06)
                : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.25)
                  : AppColors.inputBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: widget.icon,
                    size: 20,
                    color: widget.color,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
