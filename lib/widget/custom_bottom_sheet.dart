import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/const/data.dart';

class CustomBottomSheet extends StatefulWidget {
  final int? currentCalendarId;
  final Function(dynamic)? onEventAdded;
  final DateTime? startTime;
  Map<String, dynamic>? responseData;
  // for edit mode
  bool isEditMode;
  Map<String, dynamic>? event;
  final Function(int)? onEventEdited;

  CustomBottomSheet({
    super.key,
    required this.currentCalendarId,
    this.onEventAdded,
    required this.startTime,
    this.responseData,
    this.isEditMode = false,
    this.event,
    this.onEventEdited,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final dio = Dio();
  final auth = FBAuthService();

  final TextEditingController summaryController = TextEditingController();
  final TextEditingController startAtController = TextEditingController();
  final TextEditingController endAtController = TextEditingController();
  final TextEditingController priorityController =
      TextEditingController(text: '5');
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _now;
  String summary = '';
  late DateTime startAt;
  late DateTime endAt;
  String description = '';
  String location = '';

  @override
  void initState() {
    super.initState();

    if (widget.responseData != null) {
      summary = widget.responseData?['summary'];
      summaryController.text = summary;
      print("????????????????? ${summary}");

      if (widget.responseData?['startAt'] == null) {
        startAt = DateTime.now();
      } else {
        startAt = DateTime.parse(widget.responseData?['startAt']);
      }
      // startAtController.text = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR')
      //     .format(startAt);

      if (widget.responseData?['endAt'] == null) {
        endAt = startAt.add(Duration(hours: 1));
      } else {
        endAt = DateTime.parse(widget.responseData?['endAt']);
      }
      // endAtController.text = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR')
      //     .format(endAt);

      description = widget.responseData?['description'] ?? '';
      descriptionController.text = description;

      location = widget.responseData?['location'] ?? '';
      locationController.text = location;
    } else if (widget.event != null) {
      summary = widget.event?['summary'];

      if (widget.event?['startAt'] == null) {
        startAt = DateTime.now();
      } else {
        startAt = DateTime.parse(widget.event?['startAt']);
      }
      // startAtController.text = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR')
      //     .format(startAt);

      if (widget.event?['endAt'] == null) {
        endAt = startAt.add(Duration(hours: 1));
      } else {
        endAt = DateTime.parse(widget.event?['endAt']);
      }
      // endAtController.text = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR')
      //     .format(endAt);

      description = widget.event?['description'] ?? '';
      location = widget.event?['location'] ?? '';
    } else {
      print('form input: initState');
      _now = DateTime.now();
      _now = DateTime(
        _now.year,
        _now.month,
        _now.day,
        _now.hour,
        (_now.minute ~/ 5) * 5,
      );
      DateTime _end = _now.add(Duration(hours: 1));

      startAt = _now;
      endAt = _end;
    }
  }

  Future<void> _selectDate(DateTime whenAt, TextEditingController controller,
      Function(DateTime) updateWhenAt) async {
    await showModalBottomSheet(
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: whenAt,
            onDaySelected: (selectedDay, focusedDay) {
              setState(
                () {
                  controller.text = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR')
                      .format(selectedDay);
                  whenAt = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                    whenAt.hour,
                    whenAt.minute,
                  );
                  updateWhenAt(whenAt);
                },
              );
              Navigator.of(context).pop();
            },
            shouldFillViewport: true,
            daysOfWeekHeight: 30.0,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        );
      },
    );

    print('controller.text: ${controller.text}');
    print('whenAt: ${whenAt}');
  }

  Future<void> _selectTime(DateTime whenAt, TextEditingController controller,
      Function(DateTime) updateWhenAt) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            // TODO. Order: AM/PM, hour, minute
            //dateOrder: DatePickerDateTimeOrder.date_dayPeriod_time,
            // set initialDateTime adjust to minuteInterval
            initialDateTime: DateTime(
              whenAt.year,
              whenAt.month,
              whenAt.day,
              whenAt.hour,
              (whenAt.minute ~/ 5) * 5,
            ),
            minuteInterval: 5,
            onDateTimeChanged: (DateTime value) {
              setState(() {
                controller.text =
                    DateFormat('aa hh시 mm분', 'ko_KR').format(value);
                whenAt = DateTime(
                  whenAt.year,
                  whenAt.month,
                  whenAt.day,
                  value.hour,
                  value.minute,
                );
                updateWhenAt(whenAt);
              });
            },
          ),
        );
      },
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
    );
  }

  Future<void> _selectPriority(TextEditingController controller) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                controller.text = (index + 1).toString();
              });
            },
            children: List<Widget>.generate(9, (int index) {
              return Center(
                child: Text((index + 1).toString()),
              );
            }),
          ),
        );
      },
      barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
    );
  }

  Future<void> _submitForm() async {
    await auth.checkToken();
    DateTime endTime = DateTime.now();
    Duration inputTimeTaken = endTime.difference(widget.startTime!);
    double itt = inputTimeTaken.inMilliseconds / 1000;
    print('Time taken for input: ${itt.toString()}');

    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    final data = {
      'summary': summary.length != 0 ? summary : '새 일정',
      'startAt': DateFormat('yyyy-MM-ddTHH:mm:ss').format(startAt),
      'endAt': DateFormat('yyyy-MM-ddTHH:mm:ss').format(endAt),
      'description': description,
      'priority': int.parse(priorityController.text),
      'location': location,
      "status": "TENTATIVE",
      "transp": "OPAQUE",
      "calendarId": widget.currentCalendarId,
    };
    print('data: $data');

    if (!widget.isEditMode) {
      // create event
      data['inputTypeId'] = 1;
      data['inputTimeTaken'] = itt;

      final jsonData = jsonEncode(data);
      print('(create) _submitForm $jsonData');

      var resp = await dio.post(
        dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/event/form',
        data: jsonData,
        options: Options(
          headers: {
            'authorization': 'Bearer $refreshToken',
          },
        ),
      );

      print('(create) resp.statusCode: ${resp.statusCode}');
      print('(create) resp: $resp');

      if (resp.statusCode == 201) {
        widget.onEventAdded!(resp.data);
      }
    } else {
      // edit event
      data['eventId'] = widget.event?['eventId'];

      final jsonData = jsonEncode(data);
      print('(edit) _submitForm $jsonData');

      var resp = await dio.put(
        dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/event/',
        data: jsonData,
        options: Options(
          headers: {
            'authorization': 'Bearer $refreshToken',
          },
        ),
      );

      print('(edit) resp.statusCode: ${resp.statusCode}');
      print('(edit) resp: $resp');

      if (resp.statusCode == 200) {
        // TODO.
        widget.onEventEdited!(resp.data);
      }
      Navigator.of(context).pop();
    }

    Navigator.of(context).pop();
  }

  void printResponseData() {
    if (widget.responseData != null) {
      print('${widget.responseData?['summary']}');
      print('${widget.responseData?['startAt']}');
      print('${widget.responseData?['endAt']}');
      print('${widget.responseData?['location']}');
      print('${widget.responseData?['description']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    printResponseData();
    var adder = 100;
    var bottomPadding = 150;
    return Stack(
      children: [
        SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(height: 110), // Space for the fixed TextFormField

                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: TextFormField(
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            adder),
                                    controller: TextEditingController(
                                      text: DateFormat(
                                              'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                          .format(startAt),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '시작',
                                      border: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      await _selectDate(
                                          startAt, startAtController,
                                          (newDate) {
                                        startAt = newDate;
                                        // update endAt if endAt < startAt
                                        if (endAt.isBefore(startAt)) {
                                          endAt =
                                              startAt.add(Duration(hours: 1));
                                          endAtController.text = DateFormat(
                                                  'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                              .format(endAt);
                                        }
                                      });
                                    }),
                              ),
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            adder),
                                    controller: TextEditingController(
                                      text: DateFormat('aa hh시 mm분', 'ko_KR')
                                          .format(startAt),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '',
                                      border: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      await _selectTime(
                                          startAt, startAtController,
                                          (newTime) {
                                        startAt = newTime;
                                        // update endAt if endAt < startAt
                                        if (endAt.isBefore(startAt)) {
                                          endAt =
                                              startAt.add(Duration(hours: 1));
                                          endAtController.text = DateFormat(
                                                  'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                              .format(endAt);
                                        }
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 3,
                                child: TextFormField(
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            adder),
                                    controller: TextEditingController(
                                      text: DateFormat(
                                              'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                          .format(endAt),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '종료',
                                      border: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      await _selectDate(endAt, endAtController,
                                          (newDate) {
                                        endAt = newDate;
                                        // update startAt if endAt < startAt
                                        if (endAt.isBefore(startAt)) {
                                          startAt = endAt
                                              .subtract(Duration(hours: 1));
                                          startAtController.text = DateFormat(
                                                  'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                              .format(endAt);
                                        }
                                      });
                                    }),
                              ),
                              Flexible(
                                flex: 2,
                                child: TextFormField(
                                    scrollPadding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom +
                                            adder),
                                    controller: TextEditingController(
                                      text: DateFormat('aa hh시 mm분', 'ko_KR')
                                          .format(endAt),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: '',
                                      border: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      await _selectTime(endAt, endAtController,
                                          (newTime) {
                                        endAt = newTime;
// update startAt if endAt < startAt
                                        if (endAt.isBefore(startAt)) {
                                          startAt = endAt
                                              .subtract(Duration(hours: 1));
                                          startAtController.text = DateFormat(
                                                  'yyyy년 M월 dd일 (EE)', 'ko_KR')
                                              .format(endAt);
                                        }
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: TextFormField(
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        adder),
                            textAlign: TextAlign.center,
                            controller: descriptionController,
                            decoration: InputDecoration(
                              labelText: '설명',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            readOnly: false,
                            onChanged: (value) async {
                              description = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: TextFormField(
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        adder),
                            textAlign: TextAlign.center,
                            controller: priorityController,
                            decoration: InputDecoration(
                              labelText: '우선 순위',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              await _selectPriority(priorityController);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: TextFormField(
                            scrollPadding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        adder),
                            textAlign: TextAlign.center,
                            controller: locationController,
                            decoration: InputDecoration(
                              labelText: '장소',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            readOnly: false,
                            onChanged: (value) async {
                              location = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await _submitForm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              '등록',
                              style: TextStyle(
                                color: ColorPalette.GRAY_COLOR[50]!,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom +
                                bottomPadding),
                      ],
                    ),
                  ),
                ],
              ),
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
                      onPressed: () {},
                      icon: Icon(
                        Icons.keyboard_hide,
                        size: 24,
                        color: Colors.transparent,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: 0,
                        maxHeight: 0,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 100.0,
                        height: 3.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: ColorPalette.GRAY_COLOR[100]!,
                          borderRadius: BorderRadius.circular(3.0),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.only(top: 4.0),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(
                        Icons.keyboard_hide,
                        size: 24,
                      ),
                      // constraints: BoxConstraints(
                      //   maxWidth: 24,
                      //   maxHeight: 24,
                      // ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: TextFormField(
                  autofocus: summary.isEmpty,
                  // scrollPadding: EdgeInsets.only(
                  //     bottom: MediaQuery.of(context).viewInsets.bottom + adder),
                  controller: summaryController,
                  decoration: InputDecoration(
                    labelText: '일정 제목',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: '새 일정',
                  ),
                  onChanged: (value) {
                    summary = value;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
