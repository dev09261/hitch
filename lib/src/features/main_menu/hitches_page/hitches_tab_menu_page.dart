import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/group_chat/create_group_chat_page.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitches_groups_page.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitches_page.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_text_styles.dart';
import '../../../res/string_constants.dart';
import '../../../widgets/hitch_profile_image.dart';
import '../../authentication/sign_in_with_accounts_page.dart';
import '../../user_profile/user_profile.dart';

class HitchesTabMenuPage extends StatefulWidget{
  const HitchesTabMenuPage({super.key});

  @override
  State<HitchesTabMenuPage> createState() => _HitchesTabMenuPageState();
}

class _HitchesTabMenuPageState extends State<HitchesTabMenuPage> with TickerProviderStateMixin{
  late TabController _tabController;

  final List<String> _tabsTitle  = [
    'Hitches',
    'Groups'
  ];
  int selectedTab = 0;
  late Stream<DocumentSnapshot> userDocSnapshot;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    userDocSnapshot = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.bottomCenter, // Center of the container
          radius: 1.0,
          colors: [
            const Color(0xFFB5CD0D).withOpacity(0.1), // Start color
            Colors.white,      // End color
          ],

          stops: const [0.0, 0.5], // Corresponding stops
        ),),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10,top: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: StreamBuilder(
                      stream: userDocSnapshot,
                      builder: (ctx, snapshot){
                        if(snapshot.hasData){
                          if(snapshot.data!.data() != null){
                            UserModel user = UserModel.fromMap(snapshot.data!.data()! as Map<String, dynamic>);
                            return InkWell(
                                onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const UserProfile())),
                                child: user.profilePicture.isNotEmpty
                                    ? HitchProfileImage(profileUrl: user.profilePicture, size: 50,)
                                    : const HitchProfileImage(profileUrl: '', size: 50, isCurrentUser: true,));
                          }else{
                            return InkWell(
                                onTap: ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const SignInWithAccountsPage()), (route)=> false),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                                ));
                          }

                        }

                        return CircleAvatar(
                          radius: 25,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                        );
                      }),
                ),
                TabBar(
                    padding: EdgeInsets.zero,
                    labelColor: AppColors.primaryColor,
                    dividerColor: Colors.transparent,
                    unselectedLabelColor: AppColors.primaryColor,
                    labelStyle: AppTextStyles.pageHeadingStyle,
                    unselectedLabelStyle: AppTextStyles.pageHeadingStyle,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(width: 2.0, color: AppColors.primaryColor),
                      insets: EdgeInsets.symmetric(vertical: -3.0),
                    ),
                    onTap: (index){
                      if(selectedTab != index){
                        setState(()=>  selectedTab = index);
                      }
                    },
                    indicatorPadding: const EdgeInsets.only(bottom: 5),
                    tabAlignment: TabAlignment.center,
                    controller: _tabController,
                    tabs: _tabsTitle.map((tab) => Tab(text: tab,)).toList()),

                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: IconButton(
                        onPressed: selectedTab == 0
                            ? null
                            : () {
                          final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen:  false);

                          // bool isFreeConnectsCompleted = contactedPlayersProvider.contactedPlayers.isNotEmpty;
                          final isSubscribed = subscriptionProvider.getIsSubscribed;
                          if (isSubscribed) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CreateGroupChatPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>  const FilterSubscriptionPaywall()));
                          }
                        },
                        icon: Icon(
                          Icons.add,
                          size: 30,
                          color: selectedTab == 0
                              ? Colors.white
                              : AppColors.primaryColor,
                        )),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
              child: TabBarView(
                controller: _tabController,
                children:  const [
                  HitchesPage(),
                  HitchesGroupsPage()
                ],
              ))
        ],
      ),
    );
  }
}