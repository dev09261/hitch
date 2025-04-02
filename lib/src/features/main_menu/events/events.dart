import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/events/add_event_page.dart';
import 'package:hitch/src/features/main_menu/events/event_item_widget.dart';
import 'package:hitch/src/features/paywalls/filter_subscription_paywall.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/pickleball_tournament_model.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/event_service.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_text_styles.dart';
import '../../../widgets/hitch_profile_image.dart';
import '../../user_profile/user_profile.dart';
import 'pickleball_tournament_widget.dart';

class EventsPage extends StatefulWidget{
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<Tournament> pickleBallTournaments = [];
  List<EventModel> _localEvents = [];
  bool _loadingTournaments = false;
  @override
  void initState() {
    super.initState();
    _initLocalTournaments();
    _initPickleBallTournaments();
  }
  @override
  Widget build(BuildContext context) {
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder(
                  stream: UserAuthService.instance.currentUserStream,
                  builder: (ctx, snapshot){
                    if(snapshot.hasData){
                      UserModel user = snapshot.requireData;
                      return InkWell(
                          onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const UserProfile())),
                          child: user.profilePicture.isNotEmpty
                              ? HitchProfileImage(profileUrl: user.profilePicture, size: 45,)
                              : const HitchProfileImage(profileUrl: '', size: 50, isCurrentUser: true,));
                    }

                    return CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                    );
                  }),
              const Text("Events", style: AppTextStyles.pageHeadingStyle,),

              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                    onPressed: (){
                      if(isSubscribed){
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const AddEventPage()));
                      }else{
                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> const FilterSubscriptionPaywall()));
                      }
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 35,
                      color: AppColors.primaryColor,
                    )),
              )
            ],
          ),
          const SizedBox(height: 10,),
          _loadingTournaments ? const Expanded(child:  LoadingWidget()) : _buildListView(),
        ],
      ),
    );
  }

  void _initPickleBallTournaments()async {
    setState(()=>  _loadingTournaments = true);
   pickleBallTournaments = await EventService.fetchTournaments();
    _loadingTournaments = false;
   setState(() {});
  }

  void _initLocalTournaments()async {
    List<EventModel> localEventsList = await EventService.getLocalTournaments();
    if(localEventsList.isNotEmpty){
      _localEvents = localEventsList;
      setState(() {});
    }
  }

  Widget _buildListView() {
    List<dynamic> combinedList = [...pickleBallTournaments, ..._localEvents];
    return Expanded(child: ListView.builder(
        itemCount: combinedList.length,
        itemBuilder: (ctx, index){
          final item = combinedList[index];
          if(item is Tournament){
            Tournament tournament = item;
            return PickleBallTournamentItemWidget(tournament: tournament,);
          }else{
            return EventItemWidget(event: item);
          }
        }));
  }
}