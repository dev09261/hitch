import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';

class PickSportVideosPhotosWidget extends StatelessWidget{
  final VoidCallback onPickSportPhotosAndVideos;

  const PickSportVideosPhotosWidget({super.key, required this.onPickSportPhotosAndVideos});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: GestureDetector(
        onTap: onPickSportPhotosAndVideos,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderColor)
          ),
          child: SvgPicture.asset(AppIcons.icUploadImage,),
        ),
      ),
    );
  }

}