import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/user_profile/user_info_page.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/event_request_model.dart';
import 'package:hitch/src/providers/post_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostDetailsPage extends StatefulWidget {
  const PostDetailsPage({super.key, required this.event});
  final EventModel event;

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  List<EventRequestModel> requestUsers = [];
  late PostProvider _postProvider;
  bool deleting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _postProvider = Provider.of<PostProvider>(context, listen: false);
    initRequestUser();
  }

  initRequestUser() async {
    requestUsers =
        await _postProvider.getRequestsForEvent(widget.event.eventID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primaryColor,
            )),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.event.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              Text(
                DateFormat('MMM d').format(widget.event.eventDate),
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: AppColors.headingColor),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Participants (${requestUsers.length}):',
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: AppColors.headingColor),
              ),
              ...requestUsers.map((e) => _requestUserItemWidget(e)),
              const SizedBox(
                height: 40,
              ),

              if (requestUsers.isEmpty)
                const Divider(),

              deleting ?
              const Text(
                'Deleting...',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: AppColors.headingColor),
              ):
              InkWell(
                onTap: () => _onDeleteTap(),
                child: const Text(
                  'Delete event',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      color: AppColors.headingColor),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestUserItemWidget(EventRequestModel user) {
    return InkWell(
      onTap: () {
        _postProvider.readRequest(user.docId!);
        setState(() {
          user.status = 'Accepted';
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserInfoPage(player: user.requestUserId)));
      },
      child: Container(
          padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              (user.status == 'Pending')
                  ? const SizedBox(
                      width: 20,
                      child: Icon(
                        Icons.circle,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    )
                  : const SizedBox(
                      width: 20,
                    ),
              const SizedBox(
                width: 4,
              ),
              HitchProfileImage(profileUrl: user.requestUserImageUrl, size: 50),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  _getNameText(user.requestUserName),
                  style: AppTextStyles.regularTextStyle
                      .copyWith(color: Colors.black),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  'Wants to join',
                  style: AppTextStyles.regularTextStyle.copyWith(
                      color: AppColors.primaryColorVariant1,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )),
    );
  }

  String _getNameText(String userName) {
    String name = userName;
    return name.split(" ").length > 1
        ? '${name.split(' ')[0]}\n${name.split(' ')[1]}'
        : name;
  }

  void _onDeleteTap(){
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title:
          const Text("Please Confirm"),
          // content: const Text("Are you sure to delete the chat?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 16, color: AppColors.greyTextColor),),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                setState(() {
                  deleting = true;
                });
                Navigator.pop(context);
                Navigator.pop(context);
                await _postProvider.deletePost(widget.event.eventID);
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
