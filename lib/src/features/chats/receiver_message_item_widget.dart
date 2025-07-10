import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/models/chat_user_model.dart';
import 'package:hitch/src/models/messages_model.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/widgets/app_cached_network_image.dart';
import 'package:hitch/src/widgets/send_message_chat_bubble.dart';
import 'package:hitch/src/widgets/sports_photos_videos_view_page.dart';

import '../../services/chat_service.dart';
import 'linkify_text.dart';

class ReceiverMessageItemWidget extends StatefulWidget {
  final MessagesModel message;
  final Size size;
  final String roomID;
  final bool isGroupChat;
  final ChatUserModel sender;

  const ReceiverMessageItemWidget(
      {super.key,
      required this.message,
      required this.size,
      required this.roomID,
      required this.sender,
      this.isGroupChat = false});

  @override
  State<ReceiverMessageItemWidget> createState() =>
      _ReceiverMessageItemWidgetState();
}

class _ReceiverMessageItemWidgetState extends State<ReceiverMessageItemWidget> {
  @override
  void initState() {
    _isReadByRecipient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.size.width * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15.0, left: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isGroupChat)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    widget.sender.userName,
                    style: AppTextStyles.regularTextStyle,
                  ),
                ),
              CustomPaint(
                painter: CustomChatBubble(
                    color: const Color(0xffECECEC), isOwn: false),
                child: Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xffECECEC),
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(
                        horizontal: widget.message.type == 'text' ? 25 : 15,
                        vertical: 15),
                    child: widget.message.type == 'text'
                        ? LinkifyTextMessage(
                            messageText: widget.message.messageText,
                            isReceiver: true,
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => SportsPhotosVideosViewPage(
                                          uploadedFilesUrls: [
                                            widget.message.fileUrl
                                          ],
                                          selectedIndex: 0)));
                            },
                            child: AppCachedNetworkImage(
                                file: widget.message.fileUrl),
                          )
                    // SelectableText(widget.message.messageText, textAlign: TextAlign.start, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),)
                    ),
              ),
            ],
          ),
        ),
      ),
    );
    /* return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: widget.size.width*0.7
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0, left: 25),
              child: CustomPaint(
                painter: CustomChatBubble(color: const Color(0xffECECEC), isOwn: false),
                child: Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: const Color(0xffECECEC),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: Text(widget.message.messageText, textAlign: TextAlign.end, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),)
                ),
              ),
            ),
          ],
        ),
      ),
    );*/
  }

  Future<void> _isReadByRecipient() async {
    if (!widget.message.isReadByReceiver) {
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      //Mark it as read
      if (widget.isGroupChat) {
        bool isRead = widget.message.readByUsers.contains(currentUID);
        if (!isRead) {
          await ChatService.markGroupMessageAsRead(
              messageID: widget.message.messageID, roomID: widget.roomID);
        }
      } else {
        await ChatService.markAsRead(
            messageID: widget.message.messageID, roomID: widget.roomID);
      }
    }
  }
}
