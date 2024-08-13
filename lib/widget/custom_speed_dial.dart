import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../common/const/color.dart';
import 'package:flutter/material.dart';

import '../screens/calendar/schedule_bottom_sheet.dart';

class CustomSpeedDial extends StatelessWidget {
  const CustomSpeedDial({super.key});

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
              context: context,
              isDismissible: true, // 배경 탭했을 때 BottomSheet 닫기
              isScrollControlled: true,
              builder: (_) => ScheduleBottomSheet(),
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
          onTap: () {},
        ),
        SpeedDialChild(
          shape: CircleBorder(),
          child: const Icon(
            Icons.voice_chat,
            color: Colors.white,
          ),
          label: '음성 입력',
          backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
          onTap: () {},
        )
      ],
    );
  }
}
