import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/services/auth_service.dart';

import '../common/const/color.dart';
import '../common/const/data.dart';

class CustomSidebarModal extends StatefulWidget {
  final List<dynamic>? calendarList;
  final Function(int)? onCalendarSelected;
  final Set<int>? displayCalendarIdSet;
  final Function? onCalendarCreated;

  CustomSidebarModal({
    required this.calendarList,
    required this.onCalendarSelected,
    required this.displayCalendarIdSet,
    this.onCalendarCreated,
  });

  @override
  State<CustomSidebarModal> createState() => _CustomSidebarModalState();
}

class _CustomSidebarModalState extends State<CustomSidebarModal> {
  final FBAuthService auth = FBAuthService();
  final dio = Dio();

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
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Image.asset(
                      'asset/img/logo/logo.png',
                      height: 34,
                    ),
                  ),
                  const SizedBox(width: 14.0),
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
            Expanded(
                child: Column(
              children: [
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
                      title: Text(
                          '캘린더 ${'(${widget.calendarList![i]['calendarId']})'}'),
                      onTap: () {
                        setState(() {
                          if (selectedCalendarIds.contains(
                              widget.calendarList![i]['calendarId'])) {
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
                  ),
                Spacer(),
                Container(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        const SizedBox(width: 8.0),
                        Text('캘린더 만들기'),
                      ],
                    ),
                    onTap: () async {
                      // TODO: create a new calendar
                      auth.checkToken();
                      var refreshToken =
                          await storage.read(key: REFRESH_TOKEN_KEY);
                      var data = {
                        "title": "새 캘린더",
                        "timezone": "Asia/Seoul",
                        "colorSetId": 1
                      };
                      var resp = await dio.post(
                        dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/calendars/',
                        data: data,
                        options: Options(
                          headers: {
                            'authorization': 'Bearer $refreshToken',
                          },
                        ),
                      );
                      print('캘린더 생성 ${resp.statusCode}');
                      print('캘린더 생성 ${resp.data}');

                      Navigator.of(context).pop();

                      if (widget.onCalendarCreated != null) {
                        widget.onCalendarCreated!();
                      }

                      if (widget.onCalendarSelected != null) {
                        widget.onCalendarSelected!(resp.data);
                      }
                    },
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                      color: ColorPalette.GRAY_COLOR[100]!.withOpacity(0.5),
                      width: 1.0,
                    )),
                  ),
                ),
              ],
            )),

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

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
