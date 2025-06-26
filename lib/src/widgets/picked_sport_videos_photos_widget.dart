import 'package:flutter/cupertino.dart';
import 'package:hitch/src/widgets/pick_sport_videos_photos_widget.dart';
import 'package:hitch/src/widgets/selected_videos_photos_gridview_widget.dart';

class PickedSportVideosPhotosWidget extends StatelessWidget{
  const PickedSportVideosPhotosWidget({super.key, required this.pickedFiles, required this.onPickSportVideos, this.onPhotosTap, this.onRemoveTap});
  final List<String> pickedFiles;
  final VoidCallback onPickSportVideos;
  final Function(int index)? onPhotosTap;
  final Function(int index)? onRemoveTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SelectedVideosPhotosGridviewWidget(selectedPhotosVideos: pickedFiles, onTap: onPhotosTap, onRemove: onRemoveTap,),),
          const SizedBox(width: 10,),
          Expanded(
              flex: 2,
              child: PickSportVideosPhotosWidget(onPickSportPhotosAndVideos: onPickSportVideos,))
        ],
      ),
    );
  }

}