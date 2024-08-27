import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';

import '../common/const/color.dart';
import '../common/const/data.dart';
import '../services/auth_service.dart';

class CustomEventSheet extends StatelessWidget {
  final Map<String, dynamic> event;
  final List<dynamic>? eventList;
  final Function(List<dynamic>?) updateEventList;
  final Function(int) onEventEdited;
  // for back button
  final BuildContext parentContext;
  final Map<String, List<Map<String, dynamic>>> dateEvents;
  final Function(BuildContext, Map<String, List<Map<String, dynamic>>>)
      showDaysEventsModal;
  // auth
  final FBAuthService auth = FBAuthService();
  final dio = Dio();

  CustomEventSheet({
    super.key,
    required this.event,
    required this.parentContext,
    required this.dateEvents,
    required this.showDaysEventsModal,
    required this.eventList,
    required this.updateEventList,
    required this.onEventEdited,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                SizedBox(height: 110),
                Expanded(
                    child: ListView(
                  children: [
                    //for (var key in event.keys)
                    ListTile(
                      title: Text('시작'),
                      subtitle: Text(
                          DateFormat('yyyy년 M월 dd일 (EE) aa h시 m분', 'ko_KR')
                              .format(DateTime.parse(event['startAt']))),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('종료'),
                      subtitle: Text(
                          DateFormat('yyyy년 M월 dd일 (EE) aa h시 m분', 'ko_KR')
                              .format(DateTime.parse(event['endAt']))),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('장소'),
                      subtitle: Text(event['location'].toString() == 'null'
                          ? ''
                          : event['location'].toString()),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('설명'),
                      subtitle: Text(event['description'].toString() == 'null'
                          ? ''
                          : event['description'].toString()),
                      onTap: () {},
                    ),
                    ListTile(
                      title: Text('우선순위'),
                      subtitle: Text(event['priority'].toString()),
                      onTap: () {},
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                height: 38.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.only(top: 4.0),
                      onPressed: () {
                        Navigator.pop(context);
                        showDaysEventsModal(parentContext, dateEvents);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.only(top: 4.0),
                      onPressed: () {
                        _showPopupMenu(context);
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                event['summary'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position:
          RelativeRect.fromLTRB(100, 100, 0, 0), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('수정'),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            '삭제',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'edit') {
        // TODO. Handle edit action
        print(event);
        _showEditEventSheet(context, event);
      } else if (value == 'delete') {
        // Handle delete action
        _showDeleteConfirmationDialog(context);
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('삭제 확인'),
          content: Text('정말로 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                var resp = await MainRequest().deleteEvent(event['eventId']);

                if (resp.statusCode == 200) {
                  // delete event from dataEvents
                  String dateKey = DateFormat('yyyy-MM-dd')
                      .format(DateTime.parse(event['startAt']));
                  dateEvents[dateKey]!.removeWhere(
                      (element) => element['eventId'] == event['eventId']);
                  eventList!.removeWhere(
                      (element) => element['eventId'] == event['eventId']);
                  updateEventList(eventList);
                }

                showDaysEventsModal(parentContext, dateEvents);
              },
              child: Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditEventSheet(BuildContext context, Map<String, dynamic> event) {
    showModalBottomSheet(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return CustomBottomSheet(
          currentCalendarId: event['calendarId'],
          //onEventAdded: onEventAdded,
          startTime: DateTime.now(),
          isEditMode: true,
          event: event,
          onEventEdited: onEventEdited,
        );
        return Container();
      },
    );
  }
}
