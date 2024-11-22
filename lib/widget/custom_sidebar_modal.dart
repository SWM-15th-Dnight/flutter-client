import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/common/component/custom_app_bar.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/widget/modal.dart';

import '../common/component/snackbar_helper.dart';
import '../common/const/color.dart';
import '../common/const/data.dart';
import '../entities/calendar.dart';
import '../entities/color_map.dart';

class CustomSidebarModal extends StatefulWidget {
  final Map<int, Calendar> calendarMap;
  final int? currentCalendarId;
  final Function(int)? onCalendarSelected;
  final Function(int)? onSelectedCalendarDeleted;
  final Function? onCalendarCreated;
  final ColorMap colorMap;

  CustomSidebarModal({
    required this.calendarMap,
    required this.onCalendarSelected,
    this.onCalendarCreated,
    this.onSelectedCalendarDeleted,
    required this.currentCalendarId,
    required this.colorMap,
  });

  @override
  State<CustomSidebarModal> createState() => _CustomSidebarModalState();
}

class _CustomSidebarModalState extends State<CustomSidebarModal> {
  final FBAuthService auth = FBAuthService();
  final dio = Dio();

  Set<int> selectedDeletingCalendarIds = {};

  // for deleting calendar
  bool isDeleteMode = false;

  // for select calendar layout
  bool selectedCalendarLayout = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (var test in widget.calendarMap.values) {
      print('test.colorSetId: ${test.colorSetId}');
    }

    // TODO: implement build
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Column(
          children: [
            // AppBar with shadow-appbar
            Container(
              decoration: BoxDecoration(
                color: ColorPalette.GRAY_COLOR[50]!,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomAppBar(
                leftWidget: Image.asset(
                  'asset/img/logo/logo.png',
                  height: 34,
                ),
                centerContent: Text(
                  'Calinify',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Rockwell',
                  ),
                ),
                rightWidget: IconButton(
                  icon: Icon(isDeleteMode ? Icons.check : Icons.edit),
                  onPressed: _toggleDeleteMode,
                ),
                gutterSize: 20.0,
              ),
            ),
            Expanded(
                child: Column(
              children: [
                // Select Calendar Layout
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      Icons.calendar_view_day,
                      color: ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  title: Text(
                    '타임라인으로 보기',
                    style: TextStyle(
                      color: ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  onTap: () {
                    // TODO.
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      Icons.calendar_view_week,
                      color: ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  title: Text(
                    '주간 일정 보기',
                    style: TextStyle(
                      color: ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  onTap: () {
                    // TODO.
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      Icons.calendar_view_month,
                      color: selectedCalendarLayout
                          ? ColorPalette.PRIMARY_COLOR[300]!
                          : ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  title: Text(
                    '월간 일정 보기',
                    style: TextStyle(
                      color: selectedCalendarLayout
                          ? ColorPalette.PRIMARY_COLOR[300]!
                          : ColorPalette.GRAY_COLOR[600]!,
                    ),
                  ),
                  tileColor: selectedCalendarLayout
                      ? ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1)
                      : Colors.transparent,
                  onTap: () {
                    // TODO.
                  },
                ),
                // Divider with padding
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    thickness: 1.0,
                    color: ColorPalette.GRAY_COLOR[100]!,
                    height: 0,
                  ),
                ),
                // List of Calendars
                for (var cal in widget.calendarMap.values)
                  containerList(cal, widget.colorMap),
                // Divider with padding
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    thickness: 1.0,
                    color: ColorPalette.GRAY_COLOR[100]!,
                    height: 0,
                  ),
                ),
                // Add Calendar Tile
                Container(
                  decoration: BoxDecoration(
                    color: isDeleteMode ? Colors.red : null,
                    border: Border(
                        top: BorderSide(
                      color: ColorPalette.GRAY_COLOR[100]!.withOpacity(0.5),
                      width: 1.0,
                    )),
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isDeleteMode) Icon(Icons.add),
                        const SizedBox(width: 8.0),
                        Text(
                          isDeleteMode ? '캘린더 삭제' : '캘린더 만들기',
                          style: TextStyle(
                            color: isDeleteMode ? Colors.white : null,
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (isDeleteMode) {
                        if (selectedDeletingCalendarIds.isEmpty) {
                          Navigator.of(context).pop();
                          showSnackbar(context, '삭제할 캘린더를 선택하세요.');
                          return;
                        }
                        if (selectedDeletingCalendarIds.length ==
                            widget.calendarMap!.length) {
                          Navigator.of(context).pop();
                          showSnackbar(context, '모든 캘린더를 삭제할 수 없습니다.');
                          return;
                        }
                        _deleteSelectedCalendars(
                            context, selectedDeletingCalendarIds);
                      } else {
                        _showCreateCalendarDialog(context);
                      }
                    },
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  void editModal(context, calendar) {
    modal(
        context,
        calendar.title,
        Column(children: [
          Text("색상 변경"),
          Spacer(),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.delete),
            label: const Text("캘린더 삭제"),
            iconAlignment: IconAlignment.start,
            style: TextButton.styleFrom(backgroundColor: Colors.red),
          ),
        ]));
  }

  Widget containerList(calendar, colorMap) {
    return ListTile(
      leading: !isDeleteMode
          ? Checkbox(
              value: calendar.isSelected,
              onChanged: (bool? value) {},
              activeColor: colorMap.get(calendar.colorSetId),
            )
          : Checkbox(
              value: selectedDeletingCalendarIds.contains(calendar.id),
              onChanged: (bool? value) {}),
      title: Text(calendar.title),
      trailing: IconButton(
        icon: Icon(
          Icons.more_horiz,
          color: ColorPalette.GRAY_COLOR[400]!,
        ),
        onPressed: () {
          editModal(context, calendar);
        },
      ),
      onTap: () {
        setState(() {
          if (!isDeleteMode) {
            calendar.isSelected = !calendar.isSelected;
          } else {
            if (selectedDeletingCalendarIds.contains(calendar.id)) {
              selectedDeletingCalendarIds.remove(calendar.id);
            } else {
              selectedDeletingCalendarIds.add(calendar.id);
            }
          }
        });

        // set calendarId to the selected calendar
        if (widget.onCalendarSelected != null) {
          widget.onCalendarSelected!(calendar.id);
        }
      },
    );
  }

  void _toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
    });
  }

  void _deleteSelectedCalendars(BuildContext context, Set<int> calendarIds) {
    int primaryCalendarId = widget.calendarMap.keys.reduce(min);

    if (calendarIds.contains(primaryCalendarId)) {
      Navigator.of(context).pop();
      showSnackbar(context, '기본 캘린더는 삭제할 수 없습니다.');
      return;
    }

    String title = widget.calendarMap[calendarIds.first]!.title;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: calendarIds.length == 1
                ? Text("'${title}'를 삭제합니다.")
                : Text("'${title}' 등 ${calendarIds.length}개의 캘린더를 삭제합니다."),
            content: Text('삭제된 캘린더와 일정 정보는 복구할 수 없습니다. 계속하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  await auth.checkToken();
                  var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
                  for (var calendarId in calendarIds) {
                    var resp = await dio.delete(
                      dotenv.env['BACKEND_MAIN_URL']! +
                          '/api/v1/calendars/$calendarId',
                      options: Options(
                        headers: {
                          'authorization': 'Bearer $refreshToken',
                        },
                      ),
                    );
                    print('캘린더 삭제 ${resp.statusCode}');
                    print('캘린더 삭제 ${resp.data}');
                  }

                  if (calendarIds.contains(widget.currentCalendarId)) {
                    if (widget.onSelectedCalendarDeleted != null) {
                      widget.onSelectedCalendarDeleted!(primaryCalendarId);
                    }
                  }

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  if (widget.onCalendarCreated != null) {
                    widget.onCalendarCreated!();
                  }

                  // TODO. 현재 선택된 캘린더가 지워지면..., 집합도 관리해야 함.
                },
                child: Text('삭제'),
              ),
            ],
          );
        });
  }

  void _showCreateCalendarDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('캘린더 이름을 입력하세요.'),
          content: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '새 캘린더',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                String title = _titleController.text == ''
                    ? '새 캘린더'
                    : _titleController.text;

                await auth.checkToken();
                var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
                var data = {
                  "title": title,
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
                Navigator.of(context).pop();

                if (widget.onCalendarCreated != null) {
                  widget.onCalendarCreated!();
                }

                if (widget.onCalendarSelected != null) {
                  widget.onCalendarSelected!(resp.data);
                }
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
