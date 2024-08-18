import 'package:flutter/material.dart';

class CustomSidebarModal extends StatefulWidget {
  final List<dynamic>? calendarList;
  final Function(int)? onCalendarSelected;
  final Set<int>? displayCalendarIdSet;

  CustomSidebarModal({
    required this.calendarList,
    required this.onCalendarSelected,
    required this.displayCalendarIdSet,
  });

  @override
  State<CustomSidebarModal> createState() => _CustomSidebarModalState();
}

class _CustomSidebarModalState extends State<CustomSidebarModal> {
  Set<int> selectedCalendarIds = {};

  @override
  void initState() {
    super.initState();
    selectedCalendarIds = widget.displayCalendarIdSet!;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Image.asset(
                    'asset/img/logo/logo.png',
                    height: 34,
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: Text(
                      'Calinify',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Rockwell',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TODO. sort by calendarId (convert calendarList type, map to something iterable)
            for (var i = 0; i < widget.calendarList!.length; i++)
              Container(
                child: ListTile(
                  leading: Checkbox(
                    value: selectedCalendarIds
                        .contains(widget.calendarList![i]['calendarId']),
                    onChanged: (bool? value) {
                      /*
                      setState(
                        () {
                          if (value == true) {
                            selectedCalendarIds
                                .add(widget.calendarList![i]['calendarId']);
                          } else {
                            selectedCalendarIds
                                .remove(widget.calendarList![i]['calendarId']);
                          }
                        },
                      );
                      */
                    },
                  ),
                  title: Text('캘린더 ${i != 0 ? '(${i})' : ''}'),
                  onTap: () {
                    setState(() {
                      if (selectedCalendarIds
                          .contains(widget.calendarList![i]['calendarId'])) {
                        selectedCalendarIds
                            .remove(widget.calendarList![i]['calendarId']);
                      } else {
                        selectedCalendarIds
                            .add(widget.calendarList![i]['calendarId']);
                      }
                    });

                    // set calendarId to the selected calendar
                    if (widget.onCalendarSelected != null) {
                      widget.onCalendarSelected!(
                          widget.calendarList![i]['calendarId']);
                    }
                    print(
                        '(custom_sidebar_modal.dart) selectedCalendarIds: $selectedCalendarIds');
                  },
                ),
              )
            /*
                ...calendarList!.map((calendar) {
                  return ListTile(
                    title: Text('캘린더 ${calendar['calendarId']}번'),
                    onTap: () {
                      // set calendarId to the selected calendar
                      if (onCalendarSelected != null) {
                        onCalendarSelected!(calendar['calendarId']);
                      }
                    },
                  );
                }).toList(),
                */
          ],
        ),
      ),
    );
  }
}
