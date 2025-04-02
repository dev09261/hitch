import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hitch/src/features/chats/receiver_message_item_widget.dart';
import 'package:hitch/src/features/chats/sender_message_item_widget.dart';
import 'package:hitch/src/models/chat_model.dart';
import 'package:hitch/src/models/messages_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/services/app_icon_badger_service.dart';
import 'package:hitch/src/services/chat_service.dart';
import 'package:hitch/src/utils/show_snackbars.dart';
import 'package:hitch/src/widgets/loading_widget.dart';

class ChatMessagesPage extends StatefulWidget{
  const ChatMessagesPage({super.key, required this.chat});
  final ChatModel chat;

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late TextEditingController _textMessageController;
  late String _currentUID;
  late Stream<List<MessagesModel>> messagesStream;
  @override
  void initState() {
    _textMessageController = TextEditingController();
    _currentUID = FirebaseAuth.instance.currentUser!.uid;
    messagesStream = ChatService.getChatMessagesByRoomID(roomID: widget.chat.roomID);

    AppIconBadgerService.updateAppIconBadge();
    super.initState();
  }

  @override
  void dispose() {
    _textMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor,)),
        title: Text("Chat with ${widget.chat.remoteUser.userName}", style: const TextStyle(fontSize: 24, color: AppColors.primaryColor),),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: StreamBuilder(
              stream: messagesStream,
              builder: (_, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return const LoadingWidget();
                }else if(snapshot.hasError){
                  return Center(child: Text(snapshot.error.toString()),);
                }else if(snapshot.hasData){
                  return ListView.builder(
                    reverse: true,
                      itemCount: snapshot.requireData.length,
                      itemBuilder: (_, index){
                      List<MessagesModel> messages = snapshot.requireData.reversed.toList();
                    MessagesModel message = messages[index];
                      return message.senderID == _currentUID
                          ? SenderMessageItemWidget(
                              message: message,
                              size: size,
                            )
                          : ReceiverMessageItemWidget(message: message, size: size,
                        sender: widget.chat.remoteUser,
                        roomID: widget.chat.roomID,);
                    });
                }
                return const SizedBox();
              },
            )),
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      decoration:  InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                        borderSide: const BorderSide(color: AppColors.primaryDarkColor)
                      ),
                      hintText: 'Text ...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),),
                      onTapOutside: (_)=> FocusManager.instance.primaryFocus!.unfocus(),
                      controller: _textMessageController,
                      onEditingComplete: (){
                      },
                      onSubmitted: (val){
                        _onSendMessageTap(val);
                      },
                      cursorColor: AppColors.primaryDarkColor,

                )),
                  IconButton(onPressed: (){
                    String message = _textMessageController.text.trim();
                    _onSendMessageTap(message);
                  }, icon: SvgPicture.asset(AppIcons.icSendMessage))
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  void _onSendMessageTap(String val)async{
    if(val.isEmpty){
      return;
    }
    final map = await ChatService.sendMessage(roomID: widget.chat.roomID, messageText: val);
    _textMessageController.clear();
    if(!map['status']){
      _showErrorSnackBar(map);
    }
  }

  void _showErrorSnackBar(final map) {
    ShowSnackbars.showErrorSnackBar(context, errorMsgTitle: "Message Sending Failed", errorMsgTxt: map['responseMsg']);
    FocusManager.instance.primaryFocus!.unfocus();
  }
}