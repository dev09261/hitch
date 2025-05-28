import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hitch/src/models/hitches_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/services/chat_service.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/hitch_checkbox.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:hitch/src/widgets/secondary_btn.dart';

class CreateGroupChatPage extends StatefulWidget {
  const CreateGroupChatPage({super.key});

  @override
  State<CreateGroupChatPage> createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends State<CreateGroupChatPage> {
  final TextEditingController _groupNameCtrl = TextEditingController();
  bool _isLoadingUserHitches = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _groupName = '';
  final List<Map<String, dynamic>> _userHitches = [];
  bool _creatingGroupChat = false;
  bool get _isReadyToContinue => _userHitches
      .where((userHitch) => userHitch['isSelected'])
      .toList()
      .isNotEmpty;

  int step = 0;
  @override
  void initState() {
    _initUserHitches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Add a Group Chat",
          style: AppTextStyles.pageHeadingStyle,
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primaryColor,
            )),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child: step == 0
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          TextField(
                            controller: _groupNameCtrl,
                            onChanged: (v) {
                              if (v != '') {
                                setState(() {
                                  _groupName = v;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                                hintText: "Enter Group Name"),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      child: SizedBox(
                          width: 150,
                          child: _groupName == ''
                              ? SecondaryBtn(
                                  btnText: "Continue",
                                  onTap: () {
                                    Utils.showCopyToastMessage(
                                        message: 'Please add group name');
                                  },
                                )
                              : PrimaryBtn(
                                  btnText: "Continue",
                                  onTap: () {
                                    setState(() {
                                      step = 1;
                                    });
                                  },
                                  isLoading: false,
                                )),
                    )
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Add or remove Hitches",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.regularTextStyle,
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                            child: _isLoadingUserHitches
                                ? const LoadingWidget()
                                : _hasError
                                    ? Center(
                                        child: Text(
                                          _errorMessage,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.regularTextStyle,
                                        ),
                                      )
                                    : _userHitches.isEmpty
                                        ? const Center(
                                            child: Text(
                                                "You need more Hitches for a group chats. \n\nSend “Let’s Play” requests to build your Hitches.",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 21,
                                                    color: Colors.black)),
                                          )
                                        : ListView.builder(
                                            itemCount: _userHitches.length,
                                            itemBuilder: (ctx, index) {
                                              HitchesModel hitch =
                                                  _userHitches[index]['hitch'];
                                              bool isSelected =
                                                  _userHitches[index]
                                                      ['isSelected'];
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: ListTile(
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 0,
                                                      ),
                                                      leading: SizedBox(
                                                          width: 45,
                                                          child: HitchProfileImage(
                                                              profileUrl: hitch
                                                                  .user
                                                                  .profilePicture,
                                                              size: 45)),
                                                      title: Text(
                                                        hitch.user.userName,
                                                        style: AppTextStyles
                                                            .regularTextStyle
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black),
                                                      ),
                                                      trailing: SizedBox(
                                                          width: 50,
                                                          child: HitchCheckbox(
                                                              text: '',
                                                              onChange: (val) {
                                                                setState(() {
                                                                  _userHitches[
                                                                              index]
                                                                          [
                                                                          'isSelected'] =
                                                                      !isSelected;
                                                                });
                                                              },
                                                              value:
                                                                  isSelected)),
                                                    ),
                                                  ),
                                                  const Divider()
                                                ],
                                              );
                                            })),
                      ],
                    ),
                    Positioned(
                      bottom: 20,
                      child: SizedBox(
                        width: 150,
                        child: _isReadyToContinue
                            ? PrimaryBtn(
                                btnText: "Done",
                                onTap: _onCreateChatTap,
                                isLoading: _creatingGroupChat,
                              )
                            : SecondaryBtn(
                                btnText: "Done",
                                onTap: () {
                                  Utils.showCopyToastMessage(
                                      message:
                                          'Please add hitch to group chat');
                                }),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  void _initUserHitches() async {
    setState(() => _isLoadingUserHitches = true);
    try {
      List<HitchesModel> hitches = await HitchesService.getAcceptedHitches();
      for (var hitch in hitches) {
        _userHitches.add({'isSelected': false, 'hitch': hitch});
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      if (e is PlatformException) {
        _errorMessage = e.message!;
      }
    }
    _isLoadingUserHitches = false;
    setState(() {});
  }

  void _onCreateChatTap() async {
    setState(() => _creatingGroupChat = true);
    List<HitchesModel> hitches = _userHitches
        .where((hitch) => hitch['isSelected'])
        .toList()
        .map((filteredHitch) => filteredHitch['hitch'] as HitchesModel)
        .toList();

    try {
      await ChatService.createGroupChat(
          hitches: hitches, groupName: _groupName);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint("Exception while creating groupChat: ${e.toString()}");
    }

    setState(() => _creatingGroupChat = false);
  }
}
