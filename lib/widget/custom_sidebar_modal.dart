import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/services/auth_service.dart';

import '../common/const/color.dart';
import '../common/const/data.dart';

class CustomSidebarModal extends StatefulWidget {
  final List<dynamic>? calendarList;
  final int? currentCalendarId;
  final Function(int)? onCalendarSelected;
  final Function(int)? onSelectedCalendarDeleted;
  final Set<int>? displayCalendarIdSet;
  final Function? onCalendarCreated;

  CustomSidebarModal({
    required this.calendarList,
    required this.onCalendarSelected,
    required this.displayCalendarIdSet,
    this.onCalendarCreated,
    this.onSelectedCalendarDeleted,
    required this.currentCalendarId,
  });

  @override
  State<CustomSidebarModal> createState() => _CustomSidebarModalState();
}

class _CustomSidebarModalState extends State<CustomSidebarModal> {
  final FBAuthService auth = FBAuthService();
  final dio = Dio();

  Set<int> selectedCalendarIds = {};
  Set<int> selectedDeletingCalendarIds = {};

  // for deleting calendar
  bool isDeleteMode = false;

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
                  Spacer(),
                  IconButton(
                    onPressed: _toggleDeleteMode,
                    icon: Icon(isDeleteMode ? Icons.check : Icons.edit),
                  )
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
                      leading: !isDeleteMode
                          ? Checkbox(
                              value: selectedCalendarIds.contains(
                                  widget.calendarList![i]['calendarId']),
                              onChanged: (bool? value) {})
                          : Checkbox(
                              value: selectedDeletingCalendarIds.contains(
                                  widget.calendarList![i]['calendarId']),
                              onChanged: (bool? value) {}),
                      title: Text('${widget.calendarList![i]['title']}'),
                      onTap: () {
                        setState(() {
                          if (!isDeleteMode) {
                            if (selectedCalendarIds.contains(
                                widget.calendarList![i]['calendarId'])) {
                              selectedCalendarIds.remove(
                                  widget.calendarList![i]['calendarId']);
                            } else {
                              selectedCalendarIds
                                  .add(widget.calendarList![i]['calendarId']);
                            }
                          } else {
                            if (selectedDeletingCalendarIds.contains(
                                widget.calendarList![i]['calendarId'])) {
                              selectedDeletingCalendarIds.remove(
                                  widget.calendarList![i]['calendarId']);
                            } else {
                              selectedDeletingCalendarIds
                                  .add(widget.calendarList![i]['calendarId']);
                            }
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
                          showSnackbar('삭제할 캘린더를 선택하세요.');
                          return;
                        }
                        if (selectedDeletingCalendarIds.length ==
                            widget.calendarList!.length) {
                          Navigator.of(context).pop();
                          showSnackbar('모든 캘린더를 삭제할 수 없습니다.');
                          return;
                        }
                        _deleteSelectedCalendars(
                            context, selectedDeletingCalendarIds);
                      } else {
                        _showCreateCalendarDialog(context);
                      }
                    },
                  ),
                  decoration: BoxDecoration(
                    color: isDeleteMode ? Colors.red : null,
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

  void _toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
    });
  }

  void _deleteSelectedCalendars(BuildContext context, Set<int> calendarIds) {
    int primaryCalendarId = widget.calendarList!
        .map((calendar) => calendar['calendarId'])
        .reduce((a, b) => a < b ? a : b);

    if (calendarIds.contains(primaryCalendarId)) {
      Navigator.of(context).pop();
      showSnackbar('기본 캘린더는 삭제할 수 없습니다.');
      return;
    }

    String title = widget.calendarList!.firstWhere(
        (calendar) => calendar['calendarId'] == calendarIds.first)['title'];

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

                  // getCalendarList() at MainCalendar
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

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
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

                // getCalendarList() at MainCalendar
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
