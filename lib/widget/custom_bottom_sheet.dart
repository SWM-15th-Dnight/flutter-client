import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/common/const/color.dart';
import 'package:mobile_client/services/auth_service.dart';

import '../common/const/data.dart';

class CustomBottomSheet extends StatefulWidget {
  final int? currentCalendarId;
  final Function(dynamic)? onEventAdded;

  const CustomBottomSheet({
    super.key,
    required this.currentCalendarId,
    required this.onEventAdded,
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _selectDateTime(TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (selectedTime != null) {
        final DateTime finalDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          (selectedTime.minute ~/ 5) * 5, // Round to nearest 5 minutes
        );
        controller.text =
            DateFormat('yyyy-MM-ddTHH:mm:ss').format(finalDateTime);
      }
    }
  }

  Future<void> _submitForm() async {
    await auth.checkToken();

    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    final data = {
      'summary': summaryController.text,
      'startAt': startAtController.text,
      'endAt': endAtController.text,
      'priority': int.parse(priorityController.text),
      "status": "TENTATIVE",
      "transp": "OPAQUE",
      "calendarId": widget.currentCalendarId,
      "inputTypeId": 1,
      "inputTimeTaken": 0
    };
    final jsonData = jsonEncode(data);
    print('_submitForm $jsonData');

    var resp = await dio.post(
      dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/event/form',
      data: jsonData,
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    print('(CustomBottomSheet) resp.statusCode: ${resp.statusCode}');
    print('(CustomBottomSheet) resp: $resp');

    if (resp.statusCode == 201) {
      widget.onEventAdded!(resp.data);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 50.0,
            height: 3.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: ColorPalette.GRAY_COLOR[100]!,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Center(child: Text('일정 등록')),
                ),
                // Add form input fields here
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: summaryController,
                    decoration: InputDecoration(
                      labelText: '일정 제목',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a summary';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: startAtController,
                    decoration: InputDecoration(
                      labelText: '시작 날짜',
                    ),
                    readOnly: true,
                    onTap: () => _selectDateTime(startAtController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a start date and time';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: endAtController,
                    decoration: InputDecoration(
                      labelText: '종료 날짜',
                    ),
                    readOnly: true,
                    onTap: () => _selectDateTime(endAtController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an end date and time';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: priorityController,
                    decoration: InputDecoration(
                      labelText: '우선 순위',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a priority';
                      }
                      final int? priority = int.tryParse(value);
                      if (priority == null || priority < 1 || priority > 9) {
                        return 'Priority must be an integer between 1 and 9';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await _submitForm();
                    },
                    child: Text('등록'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
