import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';

class HitchProfileImage extends StatefulWidget {
  const HitchProfileImage({
    super.key,
    required this.profileUrl,
    required this.size,
    this.isLocalImage = false,
    this.isCurrentUser = false
  });

  final String profileUrl;
  final double size;
  final bool isLocalImage;
  final bool isCurrentUser;
  @override
  State<HitchProfileImage> createState() => _HitchProfileImageState();
}

class _HitchProfileImageState extends State<HitchProfileImage> {
  bool isError = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipOval(
        child: widget.isLocalImage ? Image.file(
          File(widget.profileUrl),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover, // This ensures the image fits inside the circle.
        ): widget.profileUrl.isEmpty ? buildEmptyProfileWidget() :
        CachedNetworkImage(
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover, imageUrl: widget.profileUrl,
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              Stack(
                alignment: Alignment.center,
                children: [
                   CircularProgressIndicator(value: downloadProgress.progress, color: AppColors.primaryColor,),
                  const Center(child: CupertinoActivityIndicator(),)
                ],
              ),
          errorWidget: (ctx, obj, stackTrace)=> CircleAvatar(
            radius: widget.size,
            backgroundColor: AppColors.primaryColor.withOpacity(0.2),
          ),
        ),
      ));
  }

  Widget buildEmptyProfileWidget(){
    return SvgPicture.asset(AppIcons.icEmptyProfileImg, height: widget.size,);
  }
}