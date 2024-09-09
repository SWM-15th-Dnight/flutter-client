import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_client/screens/calendar/form_bottom_sheet.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';
import 'package:mobile_client/widget/plain_text_input.dart';
import 'package:mobile_client/widget/speech_to_text_input.dart';
import 'package:provider/provider.dart';

import '../common/const/color.dart';
import 'package:flutter/material.dart';

import '../common/const/data.dart';
import '../riverpod/state_provider.dart';
import '../screens/calendar/schedule_bottom_sheet.dart';

class CustomSpeedDial extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(isClickedProvider);
    print('provider: $provider');

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: provider
            ? ColorPalette.PRIMARY_COLOR[300]!
            : ColorPalette.PRIMARY_COLOR[400]!,
        shape: BoxShape.circle,
      ),
      child: SpeedDial(
        animatedIcon: AnimatedIcons.add_event,
        onOpen: () =>
            ref.read(isClickedProvider.notifier).update((state) => true),
        onClose: () =>
            ref.read(isClickedProvider.notifier).update((state) => false),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        //icon: Icons.add,
        foregroundColor: Colors.white,
        overlayColor: ColorPalette.PRIMARY_COLOR[400]!,
        overlayOpacity: 0.2,
        spacing: 5.0,
        children: [
          SpeedDialChild(
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(161616.0),
            // ),
            shape: CircleBorder(),
            child: const Icon(Icons.edit, // arrow_circle_down_rounded,
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
              Icons.text_fields, //email,
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
              Icons.mic,
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
      ),
    );
  }
}
