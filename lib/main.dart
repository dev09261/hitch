import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitch/firebase_options.dart';
import 'package:hitch/src/bloc_cubit/courts_cubit/courts_cubit.dart';
import 'package:hitch/src/bloc_cubit/hitches_cubit/hitches_cubit.dart';
import 'package:hitch/src/bloc_cubit/main_menu_bloc/main_menu_bloc.dart';
import 'package:hitch/src/bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import 'package:hitch/src/bloc_cubit/user_info_cubit/user_info_cubit.dart';
import 'package:hitch/src/dynamic_link/dynamic_link_handler.dart';
import 'package:hitch/src/features/authentication/sign_in_with_accounts_page.dart';
import 'package:hitch/src/features/permissions_page.dart';
import 'package:hitch/src/models/dupr_model.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/contacted_players_provider.dart';
import 'package:hitch/src/providers/hitches_provider.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/dupr_service.dart';
import 'package:hitch/src/theme/hitch_app_theme.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'src/providers/subscription_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await DeepLinkHelper.initDynamicLinks();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ChangeNotifierProvider(create: (_) => LoggedInUserProvider()),
      ChangeNotifierProvider(create: (_) => ContactedPlayersProvider()),
      ChangeNotifierProvider(create: (_) => HitchesProvider()),

    ],
    child: const MyApp(),
  ));
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_)=> MainMenuTabChangeBloc()),
        BlocProvider(create: (_)=> PlayersCoachesCubit()),
        BlocProvider(create: (_)=> UserInfoCubit()),
        BlocProvider(create: (_)=> CourtsCubit()),
        BlocProvider(create: (_)=> HitchesCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
          title: appName,
          navigatorKey: navigatorKey, // Assign the global navigator key here
          theme: HitchAppTheme.hitchAppTheme,
          home: FutureBuilder(future: doesUserExists(), builder: (ctx, snapshot){
            if(snapshot.hasData){
              return snapshot.requireData ? const PermissionsPage() : const SignInWithAccountsPage();
            }else {
              bool isWaiting = snapshot.connectionState == ConnectionState.waiting;
              bool isError = snapshot.hasError;
              return Scaffold(
                body: SafeArea(
                  child: isWaiting
                      ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LoadingWidget(),
                                SizedBox(height: 20,),
                                Text("Getting user info ...")
                              ],
                            )
                          : isError
                      ? Center(child: Text(snapshot.error.toString()),)
                      : const SizedBox() ,
                ),
              );
            }
          })
      ),
    );
  }

  Future<bool> doesUserExists()async{
    bool result = false;
    try{
      if(FirebaseAuth.instance.currentUser != null){
        UserAuthService service = UserAuthService.instance;
        UserModel? user = await service.getCurrentUser();
        result = user!= null;

        if (user?.isConnectedToDupr ?? false) {
          Future.microtask(() async {
            DuprService().duprId = user!.myDuprID;
            DuprModel dupr = await DuprService().getDupr();
            if (dupr.status == 'success') {
              UserAuthService.instance.updateUserInfo(updatedMap: {
                'isConnectedToDupr' : true,
                'myDuprID' : dupr.duprId,
                'duprDoubleRating' : dupr.doubleRating,
                'duprSingleRating' : dupr.singleRating,
              });
            }
          });
        }

      }
    }catch(e){
      debugPrint("Exception while checking if user exists: ${e.toString()}");
    }

    return result;
  }
}
