import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/helpers/ad_helper.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/event_request_model.dart';
import 'package:hitch/src/providers/event_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/ad_video.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventItemWidget extends StatefulWidget {
  final EventModel event;
  final EventProvider eventProvider;
  const EventItemWidget(
      {super.key, required this.event, required this.eventProvider});

  @override
  State<EventItemWidget> createState() => _EventItemWidgetState();
}

class _EventItemWidgetState extends State<EventItemWidget> {
  final userAuthService = UserAuthService.instance;
  InterstitialAd? _interstitialAd;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    EventRequestModel? myEventRequest;

    for (var item in widget.eventProvider.eventRequests) {
      if (item.eventID == widget.event.eventID) {
        myEventRequest = item;
        break;
      }
    }

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 30.0, top: 20, right: 10, left: 10),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: UserAuthService.instance
                  .getUserByID(userID: widget.event.createdByUserID),
              builder: (ctx, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: CachedNetworkImageProvider(
                            snapshot.requireData!.profilePicture),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Posted by ${snapshot.requireData!.userName}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      )
                    ],
                  );
                }

                return const SizedBox();
              }),
          Text(
            widget.event.title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xff525151)),
          ),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(imageUrl: widget.event.eventImageUrl)),
          Text(
            DateFormat('MMM d').format(widget.event.eventDate),
            style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: AppColors.headingColor),
          ),
          Text(
            widget.event.description,
            style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: AppColors.darkGreyTextColor),
          ),
          if (widget.event.eventUrl != null)
            TextButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  Utils.launchAppUrl(url: widget.event.eventUrl!);
                },
                child: const Text(
                  'Event link',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor),
                )),
          const SizedBox(
            height: 8,
          ),
          if (myEventRequest == null)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: PrimaryBtn(
                        btnText: 'I\'m in',
                        borderColor: AppColors.primaryColor,
                        textColor: AppColors.primaryColor,
                        bgColor: Colors.transparent,
                        isLoading: loading,
                        onTap: () async {
                          if (loading) {
                            return;
                          }
                          setState(() {
                            loading = true;
                          });

                          final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen:  false);

                          // bool isFreeConnectsCompleted = contactedPlayersProvider.contactedPlayers.isNotEmpty;
                          final isSubscribed = subscriptionProvider.getIsSubscribed;

                          var user = await userAuthService.getCurrentUser();

                          List<Placemark> placemarks = await placemarkFromCoordinates(user!.latitude!, user.longitude!);

                          if(!isSubscribed){
                            if (placemarks[0].country == 'Canada') {
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => AdVideo(user: user,)));
                              if(!isSubscribed){
                                int _acceptCount = await widget.eventProvider.getTotalMyEventRequestCount();
                                if (_acceptCount >= 3) {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>  const FilterSubscriptionPaywall()));
                                  return;
                                }
                              }
                            } else {
                              int _acceptCount = await widget.eventProvider.getTotalMyEventRequestCount();
                              if (_acceptCount >= 3) {
                                Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>  const FilterSubscriptionPaywall()));
                                return;
                              }
                              if (_interstitialAd != null) {
                                await _interstitialAd!.show();
                              }
                            }
                          }

                          widget.eventProvider.sendRequest(widget.event);
                        }),
                  ),
                ),
              ],
            ),

          // if (myEventRequest?.status == 'Pending')
          //   Row(
          //     children: [
          //       Expanded(
          //         child: SizedBox(
          //           height: 50,
          //           child: PrimaryBtn(
          //               btnText: 'Sent Request',
          //               borderColor: AppColors.primaryColor,
          //               textColor: AppColors.primaryColor,
          //               bgColor: Colors.transparent,
          //               onTap: () {
          //
          //               }),
          //         ),
          //       ),
          //     ],
          //   ),

          if (myEventRequest != null)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: PrimaryBtn(
                        btnText: 'Sent',
                        borderColor: AppColors.greyColor,
                        textColor: AppColors.greyColor,
                        bgColor: Colors.transparent,
                        onTap: () {}),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              widget.eventProvider.sendRequest(widget.event);
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

}
