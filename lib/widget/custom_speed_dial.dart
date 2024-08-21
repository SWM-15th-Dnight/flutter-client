import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:mobile_client/screens/calendar/form_bottom_sheet.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';

import '../common/const/color.dart';
import 'package:flutter/material.dart';

import '../screens/calendar/schedule_bottom_sheet.dart';

class CustomSpeedDial extends StatelessWidget {
  final int? currentCalendarId;
  final Function(dynamic) onEventAdded;

  const CustomSpeedDial({
    super.key,
    required this.currentCalendarId,
    required this.onEventAdded,
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('지원 예정인 기능입니다.')));
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
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('지원 예정인 기능입니다.')));
          },
        )
      ],
    );
  }
}
