import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/apollo_ad_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:video_player/video_player.dart';

class AdVideo extends StatefulWidget {
  const AdVideo({super.key, required this.user});
  final UserModel user;
  @override
  State<AdVideo> createState() => _AdVideoState();
}

class _AdVideoState extends State<AdVideo> {
  late VideoPlayerController _controller;
  int _seconds = 5;
  Timer? _timer;

  bool clicked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.asset('assets/gif/ad5.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        _controller.setLooping(true);
        _controller.play();
        _startTimer();
        setState(() {});
      });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    InkWell(
                      onTap: () async {
                        await Utils.launchAppUrl(url: apolloAdUrl);
                        if (clicked) return;
                        clicked = true;
                        ApolloAdService().clicked(widget.user);
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: _controller.value.isInitialized
                              ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                              : Container(),
                        ),
                      ),
                    ),
                    Positioned(
                        right: 10,
                        top: 10,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:
                          _seconds == 0 ?
                          Container(
                            width: 20,
                            height: 20,
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ):Container(
                            width: 40,
                            height: 20,
                            color: Colors.black,
                            child: Center(
                              child: Text(
                                '$_seconds sec',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14
                                ),
                              )
                            ),
                          ),
                        ))
                  ],
                ))));
  }
}
