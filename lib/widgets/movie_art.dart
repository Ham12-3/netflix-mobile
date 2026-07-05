import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MovieArt extends StatelessWidget {
  const MovieArt({
    super.key,
    required this.url,
    required this.title,
    this.borderRadius = 8,
    this.fit = BoxFit.cover,
  });

  final String url;
  final String title;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, url) => Container(
          color: AppTheme.panelSoft,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppTheme.panelSoft,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
