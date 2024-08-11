import 'package:flutter/material.dart';
import 'package:mobile_client/widget/custom_text_form_field.dart';

class ScheduleBottomSheet extends StatefulWidget {
  const ScheduleBottomSheet({super.key});

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  String title = '';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height / 2 +
          bottomInset, // 화면 반 높이에 키보드 높이 추가하기
      color: Colors.white,
      child: Column(
        children: [
          CustomTextFormField(
            hintText: '일정을 입력해주세요.',
            onChanged: (String value) {
              title = value;
            },
          ),
          SizedBox(width: double.infinity),
          ElevatedButton(
            onPressed: () {
              // TODO.
              Navigator.of(context).pop();
            },
            child: Text(
              '등록',
            ),
          )
        ],
      ),
    );
  }
}
