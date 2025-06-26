import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/apollo_ad_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

class AdBannerVideo extends StatefulWidget {
  const AdBannerVideo({super.key, required this.user});
  final UserModel user;
  @override
  State<AdBannerVideo> createState() => _AdBannerVideoState();
}

class _AdBannerVideoState extends State<AdBannerVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset('assets/gif/ad1.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Utils.launchAppUrl(url: apolloAdUrl);
        ApolloAdService().clicked(widget.user);
      },
      child: SizedBox(
        width: double.infinity,
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : Container(),
      ),
    );
  }
}
