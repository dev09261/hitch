import 'package:flutter/material.dart';
import 'package:hitch/src/models/messages_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/widgets/send_message_chat_bubble.dart';

import 'linkify_text.dart';

class SenderMessageItemWidget extends StatelessWidget{
  final MessagesModel message;
  final Size size;
  const SenderMessageItemWidget({super.key, required this.message, required this.size,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width*0.85,
      child: Align(
        alignment: Alignment.topRight,
        child:  Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(constraints: BoxConstraints(maxWidth: size.width*0.85,),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, right: 10),
                    child: CustomPaint(
                      painter: CustomChatBubble(color: AppColors.primaryDarkColor, isOwn: true),
                      child: Container(

                          decoration: BoxDecoration(
                              color: AppColors.primaryDarkColor,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          child: LinkifyTextMessage(messageText: message.messageText,)

                          // SelectableText(message.messageText, textAlign: TextAlign.start, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),)
                      ),
                    ),
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}