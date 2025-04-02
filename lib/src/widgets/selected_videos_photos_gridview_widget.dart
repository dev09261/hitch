import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hitch/src/widgets/app_cached_network_image.dart';
import 'package:hitch/src/widgets/video_player_widget.dart';

class SelectedVideosPhotosGridviewWidget extends StatelessWidget{
  const SelectedVideosPhotosGridviewWidget({super.key, required this.selectedPhotosVideos, this.onTap});
  final List<String> selectedPhotosVideos;
  final Function(int index)? onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: MasonryGridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          scrollDirection: Axis.horizontal,
          itemCount: selectedPhotosVideos.length,
          itemBuilder: (context, index) {
            String file = selectedPhotosVideos[index];
            return GestureDetector(
              onTap: () => onTap!(index),
              child: (file.endsWith('.mp4') ||
                      file.contains('.mp4') ||
                      file.contains('.mov'))
                  ? VideoPlayerWidget(
                      videoUrl: file,
                      isLocal: !file.startsWith('https'),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: file.startsWith('http')
                          ? AppCachedNetworkImage(file: file)
                          : Image.file(File(file))),
            );
          },
        ),
      ),
    );
  }

}