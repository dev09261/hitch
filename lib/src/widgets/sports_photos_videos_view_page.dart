import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/widgets/video_player_widget.dart';

import 'app_cached_network_image.dart';

class SportsPhotosVideosViewPage extends StatefulWidget{
  const SportsPhotosVideosViewPage({super.key, required this.uploadedFilesUrls, required this.selectedIndex});
  final List<String> uploadedFilesUrls;
  final int selectedIndex;

  @override
  State<SportsPhotosVideosViewPage> createState() => _SportsPhotosVideosViewPageState();
}

class _SportsPhotosVideosViewPageState extends State<SportsPhotosVideosViewPage> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDarkColor,)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: PageView.builder(
                  onPageChanged: (index){
                    setState(()=> _currentIndex = index);
                  },
                    itemCount: widget.uploadedFilesUrls.length,
                    controller: _pageController,
                    itemBuilder: (ctx, index){
                    String file = widget.uploadedFilesUrls[_currentIndex];
                      return Center(
                        child: (file.endsWith('.mp4') || file.contains('.mp4')|| file.contains('.mov'))
                            ? VideoPlayerWidget(
                                videoUrl: file,
                                isLocal: !file.startsWith('https'),
                              )
                            : file.startsWith('https') ? AppCachedNetworkImage(file: file) : Image.file(File(file)),
                      );
                    })),
            const SizedBox(height: 20,),
            SizedBox(
              height: 50,
              child: ListView.builder(
                itemCount: widget.uploadedFilesUrls.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index){
                String file = widget.uploadedFilesUrls[index];
                bool isVideo = file.endsWith('.mp4') || file.contains('.mp4') || file.contains('.mov');
                bool isLocal = !(file.startsWith('http') || file.startsWith('https'));
                return GestureDetector(
                  onTap: (){
                    _currentIndex = index;
                    _pageController.jumpToPage(index,);
                    setState((){});
                  },
                  child: Padding(padding: const EdgeInsets.all(10), child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: _currentIndex == index ? AppColors.primaryDarkColor : Colors.transparent),
                      borderRadius: BorderRadius.circular(2)
                    ),
                      child: isVideo
                                ? VideoPlayerWidget(
                                    videoUrl: file,
                                    isLocal: isLocal,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                        child: isLocal ? Image.file(File(file)) : AppCachedNetworkImage(file: file) )
                  ),),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}

