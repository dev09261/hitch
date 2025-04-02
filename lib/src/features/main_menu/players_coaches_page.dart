import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/features/authentication/sign_in_with_accounts_page.dart';
import 'package:hitch/src/features/main_menu/players_and_coaches_widget/coaches_widget.dart';
import 'package:hitch/src/features/main_menu/players_and_coaches_widget/players_widget.dart';
import 'package:hitch/src/features/user_profile/user_profile.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/widgets/hitch_profile_image.dart';

class PlayersAndCoachesPage extends StatefulWidget{
  const PlayersAndCoachesPage({super.key});

  @override
  State<PlayersAndCoachesPage> createState() => _PlayersAndCoachesPageState();

}

class _PlayersAndCoachesPageState extends State<PlayersAndCoachesPage> with TickerProviderStateMixin{
  late TabController _tabController;

  final List<String> _tabsTitle  = [
    'Players',
    'Lessons'
  ];
  late Stream<DocumentSnapshot> userDocSnapshot;
  @override
  void initState() {
    _tabController = TabController(length: _tabsTitle.length, vsync: this);
    userDocSnapshot = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    super.initState();
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
          Padding(
            padding: const EdgeInsets.only(left: 20,top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
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
                    indicatorPadding: const EdgeInsets.only(bottom: 5),
                    tabAlignment: TabAlignment.center,
                    controller: _tabController,
                    tabs: _tabsTitle.map((tab) => Tab(text: tab,)).toList()),
                const SizedBox(width: 20,),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
              child: TabBarView(
                controller: _tabController,
                children:  const [
                  PlayersWidget(),
                  CoachesWidget()
                ],
              ))
        ],
      ),
    );
  }
}