import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/services/main_request.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';

import '../common/const/color.dart';
import '../common/const/data.dart';
import '../entities/event.dart';
import '../services/auth_service.dart';

class CustomEventSheet extends StatefulWidget {
  final DisplayEvent event;
  final Function(int) onEventEdited;
  // for back button
  final BuildContext parentContext;
  final List<DisplayEvent>? display;
  final Function(BuildContext, List<DisplayEvent>?)
      showDaysEventsModal;

  CustomEventSheet({
    super.key,
    required this.event,
    required this.parentContext,
    required this.display,
    required this.showDaysEventsModal,
    required this.onEventEdited,
  });

  @override
  State<CustomEventSheet> createState() => _CustomEventSheetState();
}

class _CustomEventSheetState extends State<CustomEventSheet> {
  // auth
  final FBAuthService auth = FBAuthService();

  final dio = Dio();

  late DateTime startAt;
  late DateTime endAt;
  DateFormat dateFormat = DateFormat('yyyy년 M월 d일 (EE)', 'ko_KR');
  DateFormat startTimeFormat = DateFormat('aa h시 mm분', 'ko_KR');
  DateFormat endTimeFormat = DateFormat('aa h시 mm분', 'ko_KR');

  bool isBothAMOrPM = false;
  String displayedDateTime = '';

  late DisplayEvent event;

  @override
  void initState() {
    super.initState();
    event = widget.event;
    _checkMultiDayEvent();

    _checkDateFormat();
    _checkStartTimeFormat();
    _checkEndTimeFormat();

    _setDisplayedDateTime();
  }

  void _checkMultiDayEvent() {
    if (widget.event.startAt.hour < 12 && widget.event.endAt.hour < 12) {
      isBothAMOrPM = true;
    } else if (widget.event.startAt.hour >= 12 && widget.event.endAt.hour >= 12) {
      isBothAMOrPM = true;
    }
  }

  void _checkDateFormat() {
    if (event.startAt.year != DateTime.now().year ||
        event.endAt.year != DateTime.now().year) {
      dateFormat = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR');
    } else {
      dateFormat = DateFormat('M월 d일 (EE)', 'ko_KR');
    }
  }

  void _checkStartTimeFormat() {
    if (event.startAt.minute == 0 && event.range == EventType.day) {
      startTimeFormat = DateFormat('aa h시', 'ko_KR');
    } else {
      startTimeFormat = DateFormat('aa h:mm', 'ko_KR');
    }
  }

  void _checkEndTimeFormat() {
    if (event.endAt.minute == 0 && event.range == EventType.day) {
      endTimeFormat = DateFormat('aa h시', 'ko_KR');
      if (isBothAMOrPM) {
        endTimeFormat = DateFormat('h시', 'ko_KR');
      }
    } else {
      endTimeFormat = DateFormat('aa h:mm', 'ko_KR');
      if (isBothAMOrPM) {
        endTimeFormat = DateFormat('h:mm', 'ko_KR');
      }
    }
  }

  void _setDisplayedDateTime() {
    displayedDateTime =
        dateFormat.format(event.startAt) + ' ' + startTimeFormat.format(event.startAt);

    if (event.range != EventType.day) {
      displayedDateTime +=
          ' ~\n' + dateFormat.format(event.endAt) + ' ' + endTimeFormat.format(event.endAt);
    } else {
      displayedDateTime += ' - ' + endTimeFormat.format(event.endAt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              children: [
                SizedBox(height: 125),
                Expanded(
                    child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text(widget.event.location.toString() == 'null'
                          ? ''
                          : widget.event.location.toString()),
                      // subtitle: Text('장소'),
                      onTap: () {},
                    ),
                    ListTile(
                      // icon for description
                      leading: Icon(Icons.comment_outlined),
                      title: Text(
                          widget.event.description.toString() == 'null'
                              ? ''
                              : widget.event.description.toString()),
                      // subtitle: Text('설명'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.flag),
                      title: Text(
                          '우선순위' + ' ' + widget.event.priority.toString()),
                      // subtitle: 'subtitle',
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
                        widget.showDaysEventsModal(
                            widget.parentContext, widget.display);
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
                widget.event.summary,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                displayedDateTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
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
        print(widget.event);
        _showEditEventSheet(context, widget.event);
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
                var resp =
                    await MainRequest().deleteEvent(widget.event.eventId);

                if (resp.statusCode == 200) {
                  // delete event from dataEvents
                  String dateKey = DateFormat('yyyy-MM-dd').format(widget.event.startAt);
                  widget.display?.removeWhere((element) => element.eventId == widget.event.eventId);
                  widget.onEventEdited(widget.event.eventId);
                }

                widget.showDaysEventsModal(
                    widget.parentContext, widget.display);
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

  void _showEditEventSheet(BuildContext context, DisplayEvent event) {
    showModalBottomSheet(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return CustomBottomSheet(
          currentCalendarId: event.calendarId,
          //onEventAdded: onEventAdded,
          startTime: DateTime.now(),
          isEditMode: true,
          event: event,
          onEventEdited: widget.onEventEdited,
        );
        return Container();
      },
    );
  }
}
