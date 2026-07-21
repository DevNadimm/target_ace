import 'package:flutter/material.dart';
import 'package:target_ace/core/components/custom_container.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:target_ace/core/shared/shimmer/shimmer_container.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CustomContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerContainer(height: 40, width: width / 2.45),
                    Spacer(),
                    ShimmerContainer(height: 40, width: width / 2.45),
                  ],
                ),
                SizedBox(height: 16),
                ShimmerContainer(height: 14, width: width / 1.9),
                SizedBox(height: 20),
                ShimmerContainer(height: 40, width: width / 2.7),
                SizedBox(height: 20),
                Row(
                  children: [
                    ShimmerContainer(height: 55, width: width / 2.45),
                    Spacer(),
                    ShimmerContainer(height: 55, width: width / 2.45),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ShimmerContainer(height: 16, width: width / 3),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 4;
              const gap = 8.0;
              final cellWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              Widget buildRow(int itemCount) {
                return Row(
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      SizedBox(
                        width: cellWidth,
                        child: i < itemCount
                            ? _quickActionBtn()
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  buildRow(4),
                  const SizedBox(height: gap),
                  buildRow(2),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _StatShimmer(),
              SizedBox(width: 12),
              _StatShimmer(),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _StatShimmer(),
              SizedBox(width: 12),
              _StatShimmer(),
            ],
          ),
          const SizedBox(height: 32),
          CustomContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(height: 20, width: width / 3),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerContainer(height: 160, width: 20),
                    ShimmerContainer(height: 140, width: 20),
                    ShimmerContainer(height: 110, width: 20),
                    ShimmerContainer(height: 160, width: 20),
                    ShimmerContainer(height: 140, width: 20),
                    ShimmerContainer(height: 50, width: 20),
                    ShimmerContainer(height: 160, width: 20),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _quickActionBtn() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerContainer(
            height: 36,
            width: 36,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          ShimmerContainer(height: 11, width: 48),
        ],
      ),
    );
  }
}

class _StatShimmer extends StatelessWidget {
  const _StatShimmer();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Expanded(
      child: CustomContainer(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ShimmerContainer(height: 38, width: 38),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(height: 16, width: width / 6),
                SizedBox(height: 8),
                ShimmerContainer(height: 12, width: width / 4.5),
              ],
            )
          ],
        ),
      ),
    );
  }
}

