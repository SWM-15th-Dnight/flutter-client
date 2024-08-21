import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_client/screens/calendar/form_bottom_sheet.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';
import 'package:mobile_client/widget/plain_text_input.dart';
import 'package:mobile_client/widget/speech_to_text_input.dart';

import '../common/const/color.dart';
import 'package:flutter/material.dart';

import '../common/const/data.dart';
import '../screens/calendar/schedule_bottom_sheet.dart';

class CustomSpeedDial extends StatelessWidget {
  final int? currentCalendarId;
  final Function(dynamic) onEventAdded;
  //DateTime? startTime;
  final FBAuthService auth;

  CustomSpeedDial({
    super.key,
    required this.currentCalendarId,
    required this.onEventAdded,
    required this.auth,
    //this.startTime,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: ColorPalette.PRIMARY_COLOR[400],
      icon: Icons.add,
      foregroundColor: Colors.white,
      spacing: 5.0,
      children: [
        SpeedDialChild(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(161616.0),
          // ),
          shape: CircleBorder(),
          child: const Icon(Icons.text_decrease, // arrow_circle_down_rounded,
              color: Colors.white),
          label: '수동으로 등록',
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
              useSafeArea: true,
              // TODO. 폼에 입력된 정보가 있을 경우, 경고창 띄우기
              isDismissible: true,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return CustomBottomSheet(
                  currentCalendarId: currentCalendarId,
                  onEventAdded: onEventAdded,
                  startTime: DateTime.now(),
                );
              },
            );
          },
        ),
        SpeedDialChild(
          shape: CircleBorder(),
          child: const Icon(
            Icons.chat, //email,
            color: Colors.white,
          ),
          label: '자연어로 등록',
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return PlainTextInput(
                  auth: auth,
                  currentCalendarId: currentCalendarId,
                  onEventAdded: onEventAdded,
                  startTime: DateTime.now(),
                  parentContext: context,
                );
              },
              isScrollControlled: true,
              useSafeArea: true,
              barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
            );
          },
        ),
        SpeedDialChild(
          shape: CircleBorder(),
          child: const Icon(
            Icons.voice_chat,
            color: Colors.white,
          ),
          label: '음성 입력',
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SpeechToTextInput(
                  auth: auth,
                  currentCalendarId: currentCalendarId,
                  onEventAdded: onEventAdded,
                  startTime: DateTime.now(),
                  parentContext: context,
                );
              },
              isScrollControlled: true,
              useSafeArea: true,
              barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
            );
          },
        )
      ],
    );
  }
}
