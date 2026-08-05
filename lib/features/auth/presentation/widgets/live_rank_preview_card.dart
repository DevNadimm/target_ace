import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/components/custom_divider.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/config/typography.dart';

class LiveRankPreviewCard extends StatelessWidget {
  const LiveRankPreviewCard({super.key});

  static const _rows = [
    (rank: 1, name: 'Rafiq Ahmed', score: 98),
    (rank: 2, name: 'Sadia Islam', score: 95),
    (rank: 3, name: 'Tanvir Hasan', score: 91),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.labelGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'LIVE Â· BCS 46th Battle',
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.labelGreen,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                '2,481 in',
                style: AppFonts.body(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final row in _rows) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: row.rank == 1
                        ? const HugeIcon(
                            icon: HugeIcons.strokeRoundedCrown,
                            color: AppColors.accentYellow,
                            size: 16,
                          )
                        : Center(
                            child: Text(
                              '${row.rank}',
                              style: AppFonts.body(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                                height: 1,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      row.name,
                      style: AppFonts.body(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${row.score}',
                    style: AppFonts.body(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          CustomDivider.dotted(),
          const SizedBox(height: 10),
          Text(
            'Sign in to see where you\u2019d rank',
            style: AppFonts.body(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}