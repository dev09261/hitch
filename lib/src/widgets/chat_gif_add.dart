import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giphy_picker/giphy_picker.dart';

class ChatGifAdd extends StatefulWidget {
  const ChatGifAdd({super.key, required this.onSubmit});
  final Function onSubmit;

  @override
  State<ChatGifAdd> createState() => _ChatGifAddState();
}

class _ChatGifAddState extends State<ChatGifAdd> {

  @override
  Widget build(BuildContext context) {

    String _secretKey =
    Platform.isAndroid?
    dotenv.env['ANDROID_GIPHY_API_KEY']!:
    dotenv.env['IOS_GIPHY_API_KEY']!;

    return Row(
      children: [
        IconButton(
            onPressed: () async {
              final gif = await GiphyPicker.pickGif(
                  context: context,
                  sticker: true,
                  fullScreenDialog: false,
                  showPreviewPage: false,
                  apiKey: _secretKey);

              if (gif?.images.original?.url != null) {
                widget.onSubmit(gif?.images.original?.url);
              }
            },
            icon: const Icon(
              Icons.gif_box_outlined,
              size: 40,
            )),
        const SizedBox(
          width: 6,
        ),
      ],
    );
  }
}
