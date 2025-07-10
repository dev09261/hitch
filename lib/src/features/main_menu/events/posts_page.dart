import 'package:flutter/material.dart';
import 'package:hitch/src/features/main_menu/events/post_details_page.dart';
import 'package:hitch/src/providers/post_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<PostProvider>(context, listen: false).getActiveEvents();
  }

  @override
  Widget build(BuildContext context) {
    final _postProvider = Provider.of<PostProvider>(context);

    return Center(
      child: Padding(
          padding:  const EdgeInsets.all(10.0),
          child:
          _postProvider.loading ?
          const CircularProgressIndicator():
          _postProvider.activeEvents.isEmpty?
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No Event Posts.', style: TextStyle(fontSize: 21),),
              SizedBox(height: 10,),
              Text('Tap “+” to post a local event',  style: TextStyle(fontSize: 21),)
            ],
          ):
          ListView(
            children: [
              ..._postProvider.activeEvents.map((e) {

                bool hasPendingRequest = false;

                for (var item in _postProvider.eventRequests) {
                  if (item.eventID == e.eventID) {
                    hasPendingRequest = true;
                    break;
                  }
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsPage(event: e)));
                  },
                  child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.grey
                              )
                          )
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (hasPendingRequest)
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.circle,
                                size: 20,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,

                                ),
                              ),
                              const SizedBox(height: 4,),
                              Text(
                                DateFormat('MMM d').format(e.eventDate),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    color: AppColors.headingColor),
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                );
              })
            ],
          )
      ),
    );
  }
}
