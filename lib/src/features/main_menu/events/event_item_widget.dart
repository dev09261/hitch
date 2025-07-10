import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hitch/src/models/event_model.dart';
import 'package:hitch/src/models/event_request_model.dart';
import 'package:hitch/src/providers/event_provider.dart';
import 'package:hitch/src/res/app_colors.dart';
import 'package:hitch/src/services/auth_service.dart';
import 'package:hitch/src/utils/utils.dart';
import 'package:hitch/src/widgets/primary_btn.dart';
import 'package:intl/intl.dart';

class EventItemWidget extends StatefulWidget {
  final EventModel event;
  final EventProvider eventProvider;
  const EventItemWidget(
      {super.key, required this.event, required this.eventProvider});

  @override
  State<EventItemWidget> createState() => _EventItemWidgetState();
}

class _EventItemWidgetState extends State<EventItemWidget> {

  bool loading = false;

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
                        onTap: () {
                          if (loading) {
                            return;
                          }
                          setState(() {
                            loading = true;
                          });
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
}
