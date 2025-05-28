import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/data/app_data.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/widgets/hitch_slider_widget.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:hitch/src/widgets/match_gendertype_widget.dart';
import 'package:provider/provider.dart';
import '../models/player_level_model.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double _distanceFromCurrentLocation = 10;
  late UserModel user;
  bool _filterTypePickleBall = false;
  bool _filterTypeTennisBall = false;
  bool _filterTypePadelBall = false;

  bool _canPop = false;

  bool loadingUserInfo = false;
  List<String> userLanguages = [];

  late List<PlayerLevelModel> _pickleBallLevelList;
  late List<PlayerLevelModel> _tennisBallLevelList;
  late List<PlayerLevelModel> _padelBallLevelList;

  PlayerLevelModel? _selectedPickleBallPlayerLevel;
  PlayerLevelModel? _selectedTennisBallPlayerLevel;
  PlayerLevelModel? _selectedPadelBallPlayerLevel;

  late List<String> matchTypeList;
  late List<String> genderList;

  String selectedMatchType = 'Both';
  String selectedGenderType = 'Both';

  final Map<String, String> padelLabel = {
    'Beg.': 'Beginner',
    'Intmd.': 'Intermediate',
    'Adv.': 'Advanced',
  };

  bool _changesLoading = false;
  @override
  void initState() {
    _pickleBallLevelList = AppData.getPickleBallPlayerLevels;
    _tennisBallLevelList = AppData.getTennisBallPlayerLevels;
    _padelBallLevelList = AppData.getPadelBallPlayerLevels;
    matchTypeList = ['Both', 'Doubles', 'Singles'];
    genderList = ['Both', 'Males', 'Females'];
    _initUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSubscribed = true;
    // bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;

    return isSubscribed
        ? PopScope(
            canPop: _canPop,
            onPopInvoked: (didPop) {
              if (_canPop) return;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  _canPop = await checkForChanges();

                  if (_canPop) {
                    if (!mounted) return;
                    // Navigator.of(context).pop();
                  }
                },
              );
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                    onPressed: () async {
                      await checkForChanges();
                      _onPopup();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppColors.primaryColor,
                    )),
                title: const Text(
                  "Filter",
                  style: AppTextStyles.pageHeadingStyle,
                ),
                centerTitle: true,
                scrolledUnderElevation: 0,
                backgroundColor:
                    _changesLoading ? Colors.black54 : Colors.white,
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: loadingUserInfo
                          ? const LoadingWidget()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Distance from current location",
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryColor,
                                      fontFamily: 'Inter'),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                HitchSliderWidget(
                                  onChange: onSliderChange,
                                  distanceFromCurrentLocation:
                                      _distanceFromCurrentLocation,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                const Text(
                                  "Type",
                                  style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primaryDarkColor),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () => setState(() =>
                                      _filterTypePickleBall =
                                          !_filterTypePickleBall),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          playerTypePickleBallValue,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        if (_filterTypePickleBall)
                                          const Icon(
                                            Icons.done,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                InkWell(
                                  onTap: () => setState(() =>
                                      _filterTypeTennisBall =
                                          !_filterTypeTennisBall),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          playerTypeTennisValue,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        if (_filterTypeTennisBall)
                                          const Icon(
                                            Icons.done,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                InkWell(
                                  onTap: () => setState(() =>
                                      _filterTypePadelBall =
                                          !_filterTypePadelBall),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          playerTypePadelValue,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        if (_filterTypePadelBall)
                                          const Icon(
                                            Icons.done,
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                if (_filterTypePickleBall)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Pickleball (DUPR)",
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryDarkColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children:
                                            _pickleBallLevelList.map((level) {
                                          String levelLabel = level.levelRank;

                                          if (levelLabel == '2.0') {
                                            levelLabel = '0.0 - 2.99';
                                          } else if (levelLabel == '3.0') {
                                            levelLabel = '3.0 - 3.99';
                                          } else if (levelLabel == '4.0') {
                                            levelLabel = '4.0 - 4.99';
                                          } else if (levelLabel == '5.0') {
                                            levelLabel = '5.0 - 5.99';
                                          } else if (levelLabel == '6.0') {
                                            levelLabel = '6.0 - 6.99';
                                          } else if (levelLabel == '7.0') {
                                            levelLabel = '7.0 - 7.99';
                                          } else if (levelLabel == '8.0') {
                                            levelLabel = '8.0 - ';
                                          }

                                          return Column(
                                            children: [
                                              InkWell(
                                                onTap: () => setState(() =>
                                                    _selectedPickleBallPlayerLevel =
                                                        level),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '$levelLabel ${level.levelTitle.split(' ').first}',
                                                        style: AppTextStyles
                                                            .regularTextStyle
                                                            .copyWith(
                                                                color: const Color(
                                                                    0xff595959)),
                                                      ),
                                                      if (_selectedPickleBallPlayerLevel ==
                                                          level)
                                                        const Icon(
                                                          Icons.done,
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (level !=
                                                  _pickleBallLevelList[
                                                      _pickleBallLevelList
                                                              .length -
                                                          1])
                                                const Divider(),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      )
                                    ],
                                  ),
                                if (_filterTypeTennisBall)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Tennis (UTR)",
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryDarkColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: _tennisBallLevelList
                                            .map((level) => Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => setState(() =>
                                                          _selectedTennisBallPlayerLevel =
                                                              level),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '${level.levelRank}  ${level.levelTitle.split(' ').first}',
                                                              style: AppTextStyles
                                                                  .regularTextStyle
                                                                  .copyWith(
                                                                      color: const Color(
                                                                          0xff595959)),
                                                            ),
                                                            if (_selectedTennisBallPlayerLevel ==
                                                                level)
                                                              const Icon(
                                                                Icons.done,
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (level !=
                                                        _tennisBallLevelList[
                                                            _tennisBallLevelList
                                                                    .length -
                                                                1])
                                                      const Divider(),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                      const SizedBox(
                                        height: 30,
                                      )
                                    ],
                                  ),
                                if (_filterTypePadelBall)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Padel",
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.primaryDarkColor),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: _padelBallLevelList
                                            .map((level) => Column(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => setState(() =>
                                                          _selectedPadelBallPlayerLevel =
                                                              level),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              '${padelLabel[level.levelRank]}',
                                                              style: AppTextStyles
                                                                  .regularTextStyle
                                                                  .copyWith(
                                                                      color: const Color(
                                                                          0xff595959)),
                                                            ),
                                                            if (_selectedPadelBallPlayerLevel ==
                                                                level)
                                                              const Icon(
                                                                Icons.done,
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (level !=
                                                        _padelBallLevelList[
                                                            _padelBallLevelList
                                                                    .length -
                                                                1])
                                                      const Divider(),
                                                  ],
                                                ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MatchGendertypeWidget(
                                  selectedType: selectedMatchType,
                                  typeList: matchTypeList,
                                  onTap: (int index) => setState(() =>
                                      selectedMatchType = matchTypeList[index]),
                                  headingTitle: 'Match Type',
                                  comingFromFilter: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MatchGendertypeWidget(
                                  selectedType: selectedGenderType,
                                  typeList: genderList,
                                  onTap: (int index) => setState(() =>
                                      selectedGenderType = genderList[index]),
                                  headingTitle: 'Gender',
                                  comingFromFilter: true,
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                    ),
                    if (_changesLoading)
                      Container(
                        height: double.infinity,
                        color: Colors.black54,
                        child: const LoadingWidget(),
                      )
                  ],
                ),
              ),
            ),
          )
        : const FilterSubscriptionPaywall();
  }

  void onSliderChange(double value) {
    _distanceFromCurrentLocation = value;
  }

  void _initUserInfo() async {
    loadingUserInfo = true;
    setState(() {});
    try {
      String currentUID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(userCollection)
          .doc(currentUID)
          .get();
      Map<String, dynamic> userMap =
          documentSnapshot.data()! as Map<String, dynamic>;
      user = UserModel.fromMap(userMap);

      List<dynamic> languages = userMap['languages'] ?? [];
      userLanguages = languages.map((language) => language.toString()).toList();
      selectedMatchType = user.matchType;
      selectedGenderType = user.genderType;
      _selectedPickleBallPlayerLevel = user.pickleBallPlayerLevel;
      _selectedTennisBallPlayerLevel = user.tennisBallPlayerLevel;
      _selectedPadelBallPlayerLevel = user.padelBallPlayerLevel;

      _filterTypePickleBall = user.playerTypePickle;
      _filterTypeTennisBall = user.playerTypeTennis;
      _filterTypePadelBall = user.playerTypePadel;
      _distanceFromCurrentLocation = user.distanceFromCurrentLocation;

      loadingUserInfo = false;
    } catch (e) {
      loadingUserInfo = false;
    }

    setState(() {});
  }

  Future<bool> checkForChanges() async {
    setState(() {
      _changesLoading = true;
    });
    bool shouldPop = false;
    Map<String, dynamic> map = {
      pickleBallPlayerLevelKey: _selectedPickleBallPlayerLevel?.toMap(),
      tennisBallPlayerLevelKey: _selectedTennisBallPlayerLevel?.toMap(),
      padelBallPlayerLevelKey: _selectedPadelBallPlayerLevel?.toMap(),
      playerTypePickleKey: _filterTypePickleBall,
      playerTypeTennisKey: _filterTypeTennisBall,
      playerTypePadelKey: _filterTypePadelBall,
      distanceFromCurrentLocationKey: _distanceFromCurrentLocation,
      matchTypeKey: selectedMatchType,
      genderTypeKey: selectedGenderType,
      'languages': []
    };

    try {
      UserModel userModel = UserModel(
          userID: user.userID,
          userName: user.userName,
          profilePicture: user.profilePicture,
          playerTypePickle: _filterTypePickleBall,
          playerTypeTennis: _filterTypeTennisBall,
          playerTypePadel: _filterTypePadelBall,
          playerTypeCoach: user.playerTypeCoach,
          bio: user.bio,
          cellNumber: user.cellNumber,
          emailAddress: user.emailAddress,
          distanceFromCurrentLocation: _distanceFromCurrentLocation,
          latitude: user.latitude,
          longitude: user.longitude,
          age: user.age,
          experience: user.experience,
          token: user.token,
          gender: user.gender,
          declinedRequestsUserIDs: user.declinedRequestsUserIDs,
          requestReceivedFromUserIDs: user.requestReceivedFromUserIDs,
          requestSentToUserIDs: user.requestSentToUserIDs,
          pickleBallPlayerLevel: _selectedPickleBallPlayerLevel,
          tennisBallPlayerLevel: _selectedTennisBallPlayerLevel,
          padelBallPlayerLevel: _selectedPadelBallPlayerLevel,
          coachPickleBallExperienceLevel: user.coachPickleBallExperienceLevel,
          coachTennisBallExperienceLevel: user.coachTennisBallExperienceLevel,
          coachPadelBallExperienceLevel: user.coachPadelBallExperienceLevel,
          uploadedSportsPhotos: user.uploadedSportsPhotos,
          matchType: selectedMatchType,
          genderType: selectedGenderType,
          availableDaysToPlay: user.availableDaysToPlay,
          isReviewed: user.isReviewed);
      context.read<LoggedInUserProvider>().setLoggedInUserInfo(userModel);
      await UserAuthService.instance.updateUserInfo(updatedMap: map);
    } catch (e) {
      debugPrint("Failed: checkForChanges: ${e.toString()}");
    }

    setState(() {
      _changesLoading = false;
    });
    return shouldPop;
  }

  void _onPopup() {
    Navigator.of(context).pop();
  }
}
