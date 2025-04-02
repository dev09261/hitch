import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;
  const VideoPlayerWidget({super.key, required this.videoUrl, this.isLocal = false});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  bool isPaused = true;
  @override
  void initState() {
    super.initState();

    if(widget.isLocal){
      _controller = VideoPlayerController.file(File(widget.videoUrl))
        ..initialize().then((_) {
          setState(() {}); // Rebuild after initialization
        });
    }else{
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
        ..initialize().then((_) {
          setState(() {}); // Rebuild after initialization
        });
    }
    _controller.setLooping(true); // Optional: Loop the video
    _controller.pause(); // Auto-play the video
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: VideoPlayer(_controller))),
        )
            : const LoadingWidget(),

           Positioned(
              left: 10,
              bottom: 10,
              child: GestureDetector(
                onTap: onPlayPauseTap,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.black54,
                  child: Center(child: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white,),),
                ),
              ))
      ],
    );
  }

  void onPlayPauseTap(){
    if(isPaused){
      _controller.play();
    }else{
      _controller.pause();
    }
    isPaused = !isPaused;
    setState(() {});
  }
}