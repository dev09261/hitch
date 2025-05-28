import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';

class LoadingWidget extends StatelessWidget{
  const LoadingWidget({super.key,
    this.color = AppColors.primaryColor,
    this.isMoreLoading = false,
    this.type = 'player'
  });
  final Color color;
  final bool isMoreLoading;
  final String type;
  @override
  Widget build(BuildContext context) {
    if (isMoreLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (type == 'player') {
      return Image.asset(
        AppIcons.loaderAnim,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.fitWidth,
      );
    }

    return Image.asset(
      AppIcons.loader1Anim,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.fitWidth,
    );

  }

}