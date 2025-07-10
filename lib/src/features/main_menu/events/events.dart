
import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/events/add_event_page.dart';
import 'package:hitch/src/features/main_menu/events/event_item_widget.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/pickleball_tournament_model.dart';
import 'package:hitch/src/providers/event_provider.dart';
import 'package:hitch/src/providers/logged_in_user_provider.dart';
import 'package:hitch/src/providers/subscription_provider.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/services/event_service.dart';
import 'package:hitch/src/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../res/app_colors.dart';
import '../../../res/app_text_styles.dart';
import '../../../widgets/hitch_profile_image.dart';
import '../../paywalls/filter_subscription_paywall.dart';
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
  final ScrollController _scrollController = ScrollController();
  int page =1;
  int limit = 50;
  bool hasMore = true;
  late EventProvider _eventProvider;

  @override
  void initState() {
    super.initState();
    _initLocalTournaments();
    _fetchPickleBallTournaments();
    _scrollController.addListener(_scrollListener);
  }
  @override
  Widget build(BuildContext context) {
    bool isSubscribed = Provider.of<SubscriptionProvider>(context).getIsSubscribed;
    _eventProvider = Provider.of<EventProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10.0),
      child: _loadingTournaments && page == 1
          ? const LoadingWidget(type: 'event',)
          : _buildListView(),
    );
  }

  _fetchPickleBallTournaments()async {
    setState(()=>  _loadingTournaments = true);
   Map<String, dynamic> tournamentMap = await EventService.fetchTournaments(page, limit);
    pickleBallTournaments.addAll(tournamentMap['tournaments']);
    hasMore = tournamentMap['hasMore'];
    page++;
    // await EventService.fetchTournamentIDs();
    _loadingTournaments = false;
   setState(() {});
  }

  _initLocalTournaments()async {
    var currentUser = Provider.of<LoggedInUserProvider>(context, listen: false).getUser;
    List<EventModel> localEventsList = await EventService.getLocalTournaments(currentUser);
    if(localEventsList.isNotEmpty){
      _localEvents = localEventsList;
      setState(() {});
    }
  }

  Widget _buildListView() {
    List<dynamic> combinedList = [..._localEvents, ...pickleBallTournaments];
    if(combinedList.length > 1){
      combinedList.sort((b, a) {
        DateTime dateA;
        DateTime dateB;

        if (a is Tournament) {
          dateA = a.dateFrom;
        } else if (a is EventModel) {
          dateA = a.eventDate;
        } else {
          return 0; // Fallback, in case of unexpected type
        }

        if (b is Tournament) {
          dateB = b.dateFrom;
        } else if (b is EventModel) {
          dateB = b.eventDate;
        } else {
          return 0;
        }

        return dateB.compareTo(dateA);
      });
    }

    if (combinedList.isEmpty) {
      return const LoadingWidget(type: 'event',);
    }

    return  ListView.builder(
        controller: _scrollController,
        itemCount: combinedList.length + (hasMore ? 1 : 0),
        itemBuilder: (ctx, index){
          if (index == combinedList.length) {
            return const SizedBox(width: 100,
              child: LoadingWidget(isMoreLoading: true,),
            );
          }
          final item = combinedList[index];
          if(item is Tournament){
            Tournament tournament = item;
            return PickleBallTournamentItemWidget(tournament: tournament,);
          }else{
            return EventItemWidget(event: item, eventProvider: _eventProvider,);
          }
        });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_loadingTournaments) {
      _fetchPickleBallTournaments();
    }
  }
}