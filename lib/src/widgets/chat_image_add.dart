import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:hitch/src/widgets/secondary_btn.dart';
import 'package:image_picker/image_picker.dart';

class ChatImageAdd extends StatefulWidget {
  const ChatImageAdd({super.key, required this.onSubmit});
  final Function onSubmit;

  @override
  State<ChatImageAdd> createState() => _ChatImageAddState();
}

class _ChatImageAddState extends State<ChatImageAdd> {
  final imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          child: IconButton(
              onPressed: () async {
                XFile? selectedMedia = await imagePicker.pickImage(
                    source: ImageSource.gallery, maxWidth: 300);
                if (selectedMedia != null) {
                  showDialog(
                      context: context,
                      builder: (context) => ImageDialog(
                        image: selectedMedia,
                        onSubmit: widget.onSubmit,
                      ));
                }
              },
              icon: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 38,
              )),
        )
      ],
    );
  }
}

class ImageDialog extends StatefulWidget {
  ImageDialog({super.key, required this.image, required this.onSubmit});
  XFile image;
  Function onSubmit;

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  final _userAuthService = UserAuthService.instance;

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20,),
                SizedBox(
                  height: 300,
                  child: Image.file(
                    File(widget.image.path),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SecondaryBtn(
                        btnText: "Cancel",
                        onTap: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(
                      width: 16,
                    ),
                    PrimaryBtn(btnText: "Submit", onTap: () async {
                      setState(() {
                        loading = true;
                      });
                      String? path = await _userAuthService.uploadFileToDatabase(widget.image);
                      widget.onSubmit(path);
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                    }),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
            if (loading) Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withAlpha(80),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        )
    );
  }
}
