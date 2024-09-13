import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/const/data.dart';

class CustomBottomSheet extends StatefulWidget {
  final int? currentCalendarId;
  final Function(dynamic)? onEventAdded;
  final DateTime startTime;
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

  final DraggableScrollableController _scrollableController =
      DraggableScrollableController();
  double _currentSize = 0.88;

  late DateTime _now;
  String summary = '';
  late DateTime startAt;
  late DateTime endAt;
  String description = '';
  String location = '';
  DateFormat dateFormat = DateFormat('M월 d일 (EE)', 'ko_KR');
  DateFormat startTimeFormat = DateFormat('aa h:mm', 'ko_KR');
  DateFormat endTimeFormat = DateFormat('aa h:mm', 'ko_KR');

  @override
  void initState() {
    super.initState();

    if (widget.responseData != null) {
      summary = widget.responseData?['summary'];
      summaryController.text = summary;

      if (widget.responseData?['startAt'] == null) {
        startAt = DateTime.now();
      } else {
        startAt = DateTime.parse(widget.responseData?['startAt']);
      }

      if (widget.responseData?['endAt'] == null) {
        endAt = startAt.add(Duration(hours: 1));
      } else {
        endAt = DateTime.parse(widget.responseData?['endAt']);
      }

      description = widget.responseData?['description'] ?? '';
      descriptionController.text = description;

      location = widget.responseData?['location'] ?? '';
      locationController.text = location;
    } else if (widget.event != null) {
      summary = widget.event?['summary'];
      summaryController.text = summary;

      if (widget.event?['startAt'] == null) {
        startAt = DateTime.now();
      } else {
        startAt = DateTime.parse(widget.event?['startAt']);
      }

      if (widget.event?['endAt'] == null) {
        endAt = startAt.add(Duration(hours: 1));
      } else {
        endAt = DateTime.parse(widget.event?['endAt']);
      }

      description = widget.event?['description'] ?? '';
      descriptionController.text = description;

      location = widget.event?['location'] ?? '';
      locationController.text = location;
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

    _checkDateFormat();
    _checkStartTimeFormat();
    _checkEndTimeFormat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollableController.isAttached) {
        _scrollableController.addListener(_handleSizeChange);
      }
    });
  }

  @override
  void dispose() {
    _scrollableController.removeListener(_handleSizeChange);
    super.dispose();
  }

  void _handleSizeChange() {
    double newSize = _scrollableController.size;

    // 0.25 또는 0.88 스냅 포인트에 도달할 때만 상태 변경
    if ((newSize <= 0.26 && _currentSize > 0.25) ||
        (newSize >= 0.87 && _currentSize < 0.88)) {
      setState(() {
        _currentSize = newSize;
      });
    }
  }

  void _checkDateFormat() {
    if (startAt.year != DateTime.now().year ||
        endAt.year != DateTime.now().year) {
      dateFormat = DateFormat('yyyy년 M월 dd일 (EE)', 'ko_KR');
    } else {
      dateFormat = DateFormat('M월 d일 (EE)', 'ko_KR');
    }
  }

  void _checkStartTimeFormat() {
    if (startAt.minute == 0) {
      startTimeFormat = DateFormat('aa h시', 'ko_KR');
    } else {
      startTimeFormat = DateFormat('aa h:mm', 'ko_KR');
    }
  }

  void _checkEndTimeFormat() {
    if (endAt.minute == 0) {
      endTimeFormat = DateFormat('aa h시', 'ko_KR');
    } else {
      endTimeFormat = DateFormat('aa h:mm', 'ko_KR');
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

      if (widget.responseData != null) {
        Navigator.of(context).pop();
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
    return DraggableScrollableSheet(
      controller: _scrollableController,
      initialChildSize: widget.isEditMode ? 1.0 : 0.88,
      minChildSize: 0.15,
      maxChildSize: widget.isEditMode ? 1.0 : 0.88,
      snapSizes: [0.25, 0.88],
      snap: !widget.isEditMode,
      builder: (context, scrollController) {
        return AnimatedBuilder(
            animation: _scrollableController,
            builder: (context, child) {
              if (_currentSize > 0.25) {
                return _buildExpandedView(context, scrollController);
              } else {
                return _buildCompactView(context, scrollController);
              }
            });
      },
    );
  }

  Widget _buildExpandedView(
      BuildContext context, ScrollController scrollController) {
    var adder = 100;
    var bottomPadding = 150;
    return Container(
      // color: Colors.blue.withOpacity(0.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              print("????????????????????");
            },
            child: Container(
              child: Column(
                children: [
                  Container(
                    height: 38.0,
                    // color for GestureDetector
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.only(top: 4.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 24,
                            //color: Colors.transparent,
                          ),
                          // constraints: BoxConstraints(
                          //   maxWidth: 0,
                          //   maxHeight: 0,
                          // ),
                        ),
                        // Align(
                        //   alignment: Alignment.topCenter,
                        //   child: Container(
                        //     width: 100.0,
                        //     height: 3.0,
                        //     margin:
                        //         const EdgeInsets.symmetric(vertical: 8.0),
                        //     decoration: BoxDecoration(
                        //       color: ColorPalette.GRAY_COLOR[100]!,
                        //       borderRadius: BorderRadius.circular(3.0),
                        //     ),
                        //   ),
                        // ),
                        IconButton(
                          padding: EdgeInsets.only(top: 4.0),
                          onPressed: () async {
                            //FocusScope.of(context).unfocus();
                            await _submitForm();
                          },
                          icon: Icon(
                            Icons.check,
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
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 2.0),
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
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Container(
                  //height: MediaQuery.of(context).size.height * 0.85,
                  color: Colors.white,
                  child: Column(
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
                                    text: dateFormat.format(startAt),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: '시작',
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    await _selectDate(
                                        startAt, startAtController, (newDate) {
                                      startAt = newDate;
                                      _checkDateFormat();
                                      // update endAt if endAt < startAt
                                      if (endAt.isBefore(startAt)) {
                                        endAt = startAt.add(Duration(hours: 1));
                                        endAtController.text =
                                            dateFormat.format(endAt);
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
                                    text: startTimeFormat.format(startAt),
                                  ),
                                  decoration: InputDecoration(
                                    labelText: '',
                                    border: InputBorder.none,
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    await _selectTime(
                                        startAt, startAtController, (newTime) {
                                      startAt = newTime;
                                      _checkStartTimeFormat();
                                      // update endAt if endAt < startAt
                                      if (endAt.isBefore(startAt)) {
                                        endAt = startAt.add(Duration(hours: 1));
                                        endAtController.text =
                                            dateFormat.format(endAt);
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
                                    text: dateFormat.format(endAt),
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
                                      _checkDateFormat();
                                      // update startAt if endAt < startAt
                                      if (endAt.isBefore(startAt)) {
                                        startAt =
                                            endAt.subtract(Duration(hours: 1));
                                        startAtController.text =
                                            dateFormat.format(endAt);
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
                                    text: endTimeFormat.format(endAt),
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
                                      _checkEndTimeFormat();
                                      // update startAt if endAt < startAt
                                      if (endAt.isBefore(startAt)) {
                                        startAt =
                                            endAt.subtract(Duration(hours: 1));
                                        startAtController.text =
                                            dateFormat.format(endAt);
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
                              bottom: MediaQuery.of(context).viewInsets.bottom +
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
                              bottom: MediaQuery.of(context).viewInsets.bottom +
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
                              bottom: MediaQuery.of(context).viewInsets.bottom +
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
                        child: TextFormField(
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  adder),
                          textAlign: TextAlign.center,
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: '알람',
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
                        child: TextFormField(
                          scrollPadding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  adder),
                          textAlign: TextAlign.center,
                          controller: locationController,
                          decoration: InputDecoration(
                            labelText: '색상',
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
                      SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom +
                              bottomPadding),

                      // Expanded(
                      //   child: ListView(
                      //     children: [
                      //
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView(
      BuildContext context, ScrollController scrollController) {
    var adder = 100;
    var bottomPadding = 150;
    return Container(
      // color: Colors.blue.withOpacity(0.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (details) {
              print("????????????????????");
            },
            child: Container(
              child: Column(
                children: [
                  Container(
                    height: 38.0,
                    // color for GestureDetector
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          padding: EdgeInsets.only(top: 4.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 24,
                            //color: Colors.transparent,
                          ),
                          // constraints: BoxConstraints(
                          //   maxWidth: 0,
                          //   maxHeight: 0,
                          // ),
                        ),
                        // Align(
                        //   alignment: Alignment.topCenter,
                        //   child: Container(
                        //     width: 100.0,
                        //     height: 3.0,
                        //     margin:
                        //         const EdgeInsets.symmetric(vertical: 8.0),
                        //     decoration: BoxDecoration(
                        //       color: ColorPalette.GRAY_COLOR[100]!,
                        //       borderRadius: BorderRadius.circular(3.0),
                        //     ),
                        //   ),
                        // ),
                        IconButton(
                          padding: EdgeInsets.only(top: 4.0),
                          onPressed: () async {
                            //FocusScope.of(context).unfocus();
                            await _submitForm();
                          },
                          icon: Icon(
                            Icons.check,
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
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 2.0),
                      child: TextFormField(
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
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, left: 16.0, bottom: 16.0, right: 16.0),
                  child: ListTile(
                    title: Center(
                      child: Text(dateFormat.format(startAt) +
                          ' ' +
                          startTimeFormat.format(startAt) +
                          ' ~\n' +
                          dateFormat.format(endAt) +
                          ' ' +
                          endTimeFormat.format(endAt)),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
