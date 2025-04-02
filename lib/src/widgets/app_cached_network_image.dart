import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/app_colors.dart';
// import 'package:flutter/material.dart';

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.file,
  });

  final String file;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: file,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
      const Center(child: CupertinoActivityIndicator(color: AppColors.primaryColor,)),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}