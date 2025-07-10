// ignore_for_file: deprecated_member_use
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hitch/src/facebook_event_tracker/fb_event_tracker.dart';
import 'package:hitch/src/features/authentication/sign_in_with_accounts_page.dart';
import 'package:hitch/src/features/main_menu/events/events_tab_menu_page.dart';
import 'package:hitch/src/features/main_menu/hitches_page/hitches_tab_menu_page.dart';
import 'package:hitch/src/features/main_menu/players_coaches_page.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/contacted_players_provider.dart';
import 'package:hitch/src/providers/event_provider.dart';
import 'package:hitch/src/providers/hitches_provider.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/providers/post_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/res/app_icons.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/hitches_service.dart';
import 'package:hitch/src/utils/show_dialogs.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../bloc_cubit/main_menu_bloc/main_menu_bloc.dart';
import '../providers/subscription_provider.dart';
import 'in_app_purchase/in_app_purchase_config.dart';
import 'main_menu/court_finder/court_finder_page.dart';

class MainMenuPage extends StatefulWidget{
   const MainMenuPage({super.key, this.comingFromNotification = 0});
   final int comingFromNotification;
  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {

  late ContactedPlayersProvider _contactedPlayersProvider;
  late SubscriptionProvider _subscriptionProvider;
  late LoggedInUserProvider _userProvider;
  
  final List<Widget> _pages = [
    const PlayersAndCoachesPage(),
    const CourtFinderPage(),
    const EventTabMenuPage(),
    const HitchesTabMenuPage(),
  ];

  bool _loadingUserInfo = true;
  final _userAuthService = UserAuthService.instance;
  @override
  void initState() {
    super.initState();
    _initAppInfo();
    // Initialize background service
    Provider.of<PostProvider>(context, listen: false).initPendingRequests();
    Provider.of<EventProvider>(context, listen: false).initMyEventRequest();
    context.read<MainMenuTabChangeBloc>().add(TabChangeEvent(tabIndex: widget.comingFromNotification));
  }
  
  @override
  Widget build(BuildContext context) {
    final tabChangeBloc = BlocProvider.of<MainMenuTabChangeBloc>(context);
    _subscriptionProvider = Provider.of<SubscriptionProvider>(context,);
    _userProvider = Provider.of<LoggedInUserProvider>(context,);
    _contactedPlayersProvider = Provider.of<ContactedPlayersProvider>(context,);
    return BlocConsumer<MainMenuTabChangeBloc, MainMenuState>(
        bloc: tabChangeBloc,
        listener: (context, state) {},
        builder: (context, state) {
          return _loadingUserInfo ? const Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(child: Padding(
                padding: EdgeInsets.only(
                    bottom: 20,
                    left: 18,
                    right: 18
                ),
                child: LoadingWidget(),
              ))
          ) : Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.grey, spreadRadius: 0.5, blurRadius: 1),
                ]
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                type: BottomNavigationBarType.fixed,
                items: [
                  _buildBottomNavigationBarItem(state, icon: AppIcons.icPlayersCoaches, label: 'Players',  index: 0),
                  _buildBottomNavigationBarItem(state, icon: AppIcons.icTennisCourt, label: 'Courts', index: 1, isTennisCourt: true),
                  BottomNavigationBarItem(icon: Builder(
                    builder: (ctx){
                      final _postProvider = Provider.of<PostProvider>(context);
                      return Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 4, right: 4
                                ),
                                child: SvgPicture.asset(
                                  AppIcons.icEvents,
                                  color: state.tabIndex == 2
                                      ? AppColors.primaryColor
                                      : AppColors.greyTextColor,
                                  height: 40,
                                ),
                              ),
                              if (_postProvider.eventRequests.isNotEmpty)
                                const Positioned(
                                  top: 4,
                                  left: -2,
                                  child: Icon(
                                    Icons.circle,
                                    size: 20,
                                    color: AppColors.primaryColor,
                                  ),
                                )
                            ],
                          ),
                          const SizedBox(height: 5,),

                          Text(
                            'Events',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: state.tabIndex == 2
                                    ? AppColors.primaryColor
                                    : AppColors.navigationIconColor),
                          )
                        ],
                      );
                    },
                  ), label: ''),

                  BottomNavigationBarItem(icon: FutureBuilder(
                    future: HitchesService.getPendingAndUnReadCount(),
                    builder: (ctx, snapshot){
                      if(snapshot.hasData){
                        bool isPendingRequestNotEmpty = snapshot.requireData > 0;
                        return Column(
                          children: [
                            const SizedBox(height: 8,),
                            isPendingRequestNotEmpty
                                ? SvgPicture.asset(AppIcons.icHitchesGreenNotSelected, color: state.tabIndex == 3
                                ? AppColors.primaryColor
                                : null) : SvgPicture.asset(
                                              AppIcons.icHitchesDefault,
                                              color: state.tabIndex == 3
                                                  ? AppColors.primaryColor
                                                  : AppColors.greyTextColor,
                                              height: 40,
                                            ),
                                      const SizedBox(height: 5,),

                                      Text(
                                        'Hitches',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: state.tabIndex == 3
                                                ? AppColors.primaryColor
                                                : AppColors.navigationIconColor),
                                      )
                                    ],
                        );
                      }

                                return SvgPicture.asset(
                                  AppIcons.icHitchesDefault,
                                  color: state.tabIndex == 3
                                      ? AppColors.primaryColor
                                      : AppColors.greyTextColor,
                                  height: 40,
                                );
                              },
                  ), label: ''),
                ],
                currentIndex: state.tabIndex,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.textFieldFillColor,
                selectedLabelStyle: const TextStyle(fontSize: 0, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                unselectedLabelStyle: const TextStyle(fontSize: 0, fontWeight: FontWeight.w600, color: Colors.grey),
                onTap: (index)=> tabChangeBloc.add(TabChangeEvent(tabIndex: index)),
              ),
            ),
            body: SafeArea(
                    child:
                    _pages.elementAt(state.tabIndex),
                  ),
                );
        });
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(MainMenuState state,
      {required String icon,
      required String label,
      required int index,
      bool isTennisCourt = false,
        Color unselectedColor = AppColors.greyTextColor,
      double height = 45}) {
    return BottomNavigationBarItem(
        icon: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            children: [
              isTennisCourt
                  ? Image.asset(icon, color: state.tabIndex == index ? AppColors.primaryColor : unselectedColor, height: 45,)
                  : SvgPicture.asset(
                      icon,
                      color: state.tabIndex == index
                          ? AppColors.primaryColor
                          : AppColors.greyTextColor,
                      height: height,
                    ),
              const SizedBox(height: 5,),
              Text(
                label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: state.tabIndex == index
                        ? AppColors.primaryColor
                        : AppColors.navigationIconColor),
              )
            ],
          ),
        ),
      label: ''
    );
  }

  void _initAppInfo()async {
    _initUserInfo();
    //Setting in-app-purchase configuration
    InAppPurchaseConfig.configInAppPurchases();
    _initUserSubscriptionInfo();
    FbEventTracker.initFbEventTracker();

    try{
     String? token =  await FirebaseMessaging.instance.getToken();
     UserAuthService.instance.updateUserInfo(updatedMap: {
       'token' : token
     });
    }catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }

      debugPrint("Error message while token generating: $errorMessage");
    }

  }

  void _initUserSubscriptionInfo() async{
    if(await Purchases.isConfigured){
      try{
        CustomerInfo customerInfo = await Purchases.getCustomerInfo();

        if(customerInfo.activeSubscriptions.isNotEmpty ){
          debugPrint("Setting to subscribe");
          _subscriptionProvider.subscribe();
        }else{
          debugPrint("Setting to unSubscribe");
          _subscriptionProvider.unsubscribe();
        }
      }catch(e){
        debugPrint("Exception while getting customerInfo: ${e.toString()}");
      }
    }
  }

  void _initUserInfo()async {
    try{
      UserModel? user = await _userAuthService.getCurrentUser();
      if(user != null){
        _userProvider.setLoggedInUserInfo(user);
        _userProvider.setIsReviewed(isReviewed: user.isReviewed);
        _contactedPlayersProvider.addContactedPlayers(user.requestSentToUserIDs);
        if(user.gender == null){
          //Show select gender dialog
          _showGenderDialog();
        }
      }else{
        _navigateToLoginPage();
      }


      HitchesService.getAcceptedHitchesUserIds().then((val){
        Provider.of<HitchesProvider>(context, listen: false).setAcceptedHitches(val);
      });
    }catch(e){
      _navigateToLoginPage();
    }

    setState(()=> _loadingUserInfo = false);
  }


  void  _navigateToLoginPage(){
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx)=> const SignInWithAccountsPage()), (route)=> false);
  }


  void _showGenderDialog() {
    ShowDialogs.showGenderDialog(context, _onPopup);
  }

  void _onPopup() {
    Navigator.of(context).pop();
  }
}