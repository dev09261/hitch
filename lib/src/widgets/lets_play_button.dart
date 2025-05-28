import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/models/pending_hitches.dart';
import 'package:hitch/src/models/user_model.dart';
import 'package:hitch/src/providers/contacted_players_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/string_constants.dart';
import 'package:provider/provider.dart';
import '../bloc_cubit/players_coaches_cubit/players_coaches_cubit.dart';
import '../helpers/ad_helper.dart';
import '../services/auth_service.dart';
import '../services/hitches_service.dart';
import 'primary_btn.dart';

class LetsPlayButton extends StatefulWidget{
  final UserModel player;
  final bool comingFromUserPage;
  const LetsPlayButton({super.key, required this.player, this.comingFromUserPage = false});

  @override
  State<LetsPlayButton> createState() => _LetsPlayButtonState();
}

class _LetsPlayButtonState extends State<LetsPlayButton> {
  bool _loadingPlayRequest = false;

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    _loadInterstitialAd();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        width: size.width*0.5,
        child: PrimaryBtn(btnText: "Let’s play", onTap: ()async{
          if(widget.comingFromUserPage){
            setState(()=> _loadingPlayRequest = true);
          }
          await onLetsPlayTap(context);
          if(widget.comingFromUserPage){
            setState(()=> _loadingPlayRequest = false);
          }
        }, isLoading: _loadingPlayRequest,));
  }



  Future<void> onLetsPlayTap(BuildContext context)async{

    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen:  false);

    // bool isFreeConnectsCompleted = contactedPlayersProvider.contactedPlayers.isNotEmpty;
    final isSubscribed = subscriptionProvider.getIsSubscribed;

    if(!isSubscribed){
      int _hitcherCount = await HitchesService.getAllHitchesCount();
      if (_hitcherCount >= 5) {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>  const FilterSubscriptionPaywall()));
        return;
      }

      if (_interstitialAd != null) {
        await _interstitialAd!.show();
      }
    }

    _sendPlayRequest();
  }

  Future<void> _addRequestSentByCurrentUser({required UserModel currentUser,required String requestSentToPlayerID})async{

    DocumentReference currentUserDocRef = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(FirebaseAuth.instance.currentUser!.uid);
    //Adding sent request to currentUser
    List<String> requestSentToUserIDs = currentUser.requestSentToUserIDs;
    requestSentToUserIDs.add(requestSentToPlayerID);
    currentUser.requestSentToUserIDs = requestSentToUserIDs;
    await currentUserDocRef.set(currentUser.toMap());

  }

  Future<void> _addRequestReceivedByPlayer({required UserModel currentUser, required UserModel requestReceiverPlayer})async{
    DocumentReference playerMap = FirebaseFirestore.instance
        .collection(userCollection)
        .doc(requestReceiverPlayer.userID);

    List<String> requestReceivedByUserIDs = requestReceiverPlayer.requestReceivedFromUserIDs;
    requestReceivedByUserIDs.add(currentUser.userID);
    requestReceiverPlayer.requestReceivedFromUserIDs = requestReceivedByUserIDs;
    await playerMap.set(requestReceiverPlayer.toMap());
  }

  // TODO: Implement _loadInterstitialAd()
  void _loadInterstitialAd() {

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _sendPlayRequest();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void _sendPlayRequest() async{
    final contactedPlayersProvider = Provider.of<ContactedPlayersProvider>(context, listen:  false);
    final playersCoachesCubit = BlocProvider.of<PlayersCoachesCubit>(context);

    UserModel? currentUser = await UserAuthService.instance.getCurrentUser();
    if(currentUser != null){
      playersCoachesCubit.onShowLetsPlayAnim();
      await Future.delayed(const Duration(seconds: 1));
      playersCoachesCubit.onHideLetsPlayAnim();

      await PendingHitchesModel(
        uid: '${currentUser.userID}${widget.player.userID}',
        senderId: currentUser.userID,
        senderName: currentUser.userName,
        senderToken: currentUser.token,
        receiverId: widget.player.userID,
        receiverName: widget.player.userName,
        receiverToken: widget.player.token,
      ).create();

      //addHitchToUser is responsible for adding hitch request to users and also sending notification and email
      await HitchesService.addHitchToUser(receiver: widget.player, sender: currentUser);

      //adding player to request sent list
      await _addRequestSentByCurrentUser(currentUser: currentUser, requestSentToPlayerID: widget.player.userID);

      //Adding request to player request received list
      await _addRequestReceivedByPlayer(currentUser: currentUser, requestReceiverPlayer: widget.player);

      contactedPlayersProvider.addToContactedPlayers(userID: widget.player.userID);
    }
  }
}