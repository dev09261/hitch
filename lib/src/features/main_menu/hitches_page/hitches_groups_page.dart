import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hitch/src/models/group_chat_model.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/services/chat_service.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import '../../../res/app_colors.dart';
import '../../group_chat/group_chat_messages_page.dart';

class HitchesGroupsPage extends StatelessWidget{
  const HitchesGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return
      Center(
      child: Padding(
        padding:  const EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: ChatService.getUserGroupChats,
          builder: (_, snapshot){
            if(snapshot.hasData){
              return snapshot.requireData.isEmpty ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No group chats.', style: TextStyle(fontSize: 21),),
                  SizedBox(height: 10,),
                  Text('Tap “+” to create a group.',  style: TextStyle(fontSize: 21),)
                ],
              ) : ListView.builder(
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (_, index){
                    List<GroupChatModel> groupChats = snapshot.requireData;
                    groupChats.sort((a, b)=> b.createdAt.compareTo(a.createdAt));
                    GroupChatModel chat = groupChats[index];
                    return Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.35,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_)=> _onRemoveChatTap(context, chat),
                              label: 'REMOVE',
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> GroupChatMessagesPage(chat: chat)));
                              },
                              contentPadding: const EdgeInsets.all(10),
                              title: Row(
                                children: [
                                  Expanded(child: Text(_groupName(chat), overflow: TextOverflow.ellipsis, maxLines: 1, style: AppTextStyles.regularTextStyle,)),
                                  Text('(${chat.members.length})'),
                                ],
                              ),
                              trailing: StreamBuilder(
                                  stream: ChatService.getGroupChatUnReadMessagesCount(roomID: chat.chatID),
                                  builder: (_, snapshot) {
                                    return Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Image.asset(
                                          AppIcons.icMessage,
                                          height: 30,
                                        ),
                                        if(snapshot.hasData && snapshot.requireData > 0)
                                          const Positioned(
                                            top: 0,
                                            left: 0,
                                            child: CircleAvatar(
                                              backgroundColor: AppColors.primaryColor,
                                              radius: 8,
                                            ),
                                          )
                                      ],
                                    );
                                  }
                              ),
                            ),
                            Container(
                              height: 1,
                              color: Colors.grey,
                            )
                          ],
                        ));
              });
            }else if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString(), textAlign: TextAlign.center, style: AppTextStyles.regularTextStyle,),);
            }else if(snapshot.connectionState == ConnectionState.waiting){
              return const LoadingWidget();
            }

            return const SizedBox();
          },
        )
      ),
    );
  }

  String _groupName(GroupChatModel groupName) {

    if (groupName.groupName != '') {
      return groupName.groupName;
    }

    String name = '';
    for (var member in groupName.members) {
      name += '${member.userName}, ';
    }
    return name.substring(0, name.length-2);
  }

  void _onRemoveChatTap(BuildContext context, GroupChatModel group){
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Please Confirm"),
          // content: const Text("Are you sure to delete the chat?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16, color: AppColors.greyTextColor),),
            ),
            CupertinoDialogAction(
              onPressed: () {
                ChatService.deleteGroupChat(group.chatID,);
                Navigator.of(context).pop();
              },
              isDestructiveAction: true, // Makes text red
              child: const Text("Delete", style: TextStyle(fontSize: 16, color: AppColors.redColor),),
            ),
          ],
        );
      },
    );
  }
}