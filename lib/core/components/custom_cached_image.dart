import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:target_ace/core/config/assets.dart';
import 'package:target_ace/core/config/colors.dart';
import 'package:shimmer/shimmer.dart';

enum PlaceholderSize { small, medium, large, extraLarge }

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String errorAsset;
  final List<List<dynamic>>? errorIcon;
  final Color? errorIconColor;
  final double aspectRatio;
  final Color backgroundColor;
  final PlaceholderSize placeholderSize;
  final double borderRadius;
  final bool useShimmer;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorAsset = Assets.noImage,
    this.errorIcon,
    this.errorIconColor,
    this.aspectRatio = 16 / 9,
    this.backgroundColor = AppColors.card,
    this.placeholderSize = PlaceholderSize.medium,
    this.borderRadius = 12.0,
    this.useShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image(
          image: imageProvider,
          fit: fit,
          width: width,
          height: height,
        ),
      ),
      placeholder: (context, url) => _buildShimmer(screenWidth),
      errorWidget: (context, url, error) =>
          _buildPlaceholderOrError(asset: errorAsset, screenWidth: screenWidth),
    );

    if (width == null && height == null) {
      return AspectRatio(aspectRatio: aspectRatio, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildShimmer(double screenWidth) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey.withValues(alpha: 0.3),
        highlightColor: AppColors.cardAlt,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: backgroundColor,
        ),
      ),
    );
  }

  Widget _buildPlaceholderOrError({
    required String asset,
    required double screenWidth,
  }) {
    double size;
    switch (placeholderSize) {
      case PlaceholderSize.small:
        size = screenWidth * 0.05;
        break;
      case PlaceholderSize.medium:
        size = screenWidth * 0.1;
        break;
      case PlaceholderSize.large:
        size = screenWidth * 0.2;
        break;
      case PlaceholderSize.extraLarge:
        size = screenWidth * 0.3;
        break;
    }

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: errorIcon != null
            ? HugeIcon(
                icon: errorIcon!,
                size: size,
                color: errorIconColor ?? AppColors.primary,
              )
            : Image.asset(
                asset,
                fit: BoxFit.contain,
                width: size,
                height: size,
              ),
      ),
    );
  }
}
