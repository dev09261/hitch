import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';

class LoadingWidget extends StatelessWidget{
  const LoadingWidget({super.key, this.color = AppColors.primaryColor});
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isAndroid
          ? CircularProgressIndicator(color: color,)
          : CupertinoActivityIndicator(color: color,),
    );
  }

}