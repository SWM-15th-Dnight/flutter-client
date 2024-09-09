import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/common/component/snackbar_helper.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';

import '../common/const/color.dart';
import '../common/const/data.dart';

class PlainTextInput extends StatefulWidget {
  final int? currentCalendarId;
  final Function(dynamic) onEventAdded;
  final DateTime startTime;
  final FBAuthService auth;
  final BuildContext? parentContext;

  PlainTextInput({
    super.key,
    required this.auth,
    required this.currentCalendarId,
    required this.onEventAdded,
    required this.startTime,
    required this.parentContext,
  });

  @override
  State<PlainTextInput> createState() => _PlainTextInputState();
}

class _PlainTextInputState extends State<PlainTextInput> {
  final dio = Dio();
  final TextEditingController plainTextController = TextEditingController();
  String? plainText;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: '예. 내일 선릉역 근처에서 저녁 식사',
                      ),
                      controller: plainTextController,
                      onChanged: (value) {
                        plainText = value;
                      },
                      // scrollPadding: EdgeInsets.only(
                      //     bottom:
                      //         MediaQuery.of(context).viewInsets.bottom),
                      autofocus: true,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      await widget.auth.checkToken();
                      var refreshToken =
                          await storage.read(key: REFRESH_TOKEN_KEY);
                      final data = {
                        'inputType': 1,
                        'originText': plainText,
                        'promptId': 1
                      };
                      final jsonData = jsonEncode(data);
                      print('plainText data: $jsonData');

                      try {
                        var resp = await dio.post(
                          dotenv.env['BACKEND_MAIN_URL']! +
                              '/api/v1/eventProcessing/plainText',
                          data: jsonData,
                          options: Options(
                            headers: {
                              'authorization': 'Bearer $refreshToken',
                            },
                          ),
                        );

                        print('(NLP) resp.statusCode: ${resp.statusCode}');
                        print('(NLP) resp: $resp');
                        print('(NLP) resp.data: ${resp.data}');
                        print(
                            '(NLP) resp.data.runtimeType: ${resp.data.runtimeType}');

                        // final responseData =
                        //     jsonDecode(resp.data) as Map<String, dynamic>;
                        // // print(
                        //     '(NLP) responseData.runtimeType: ${responseData.runtimeType}');

                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          barrierColor:
                              ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
                          useSafeArea: true,
                          // TODO. 폼에 입력된 정보가 있을 경우, 경고창 띄우기
                          isDismissible: true,
                          isScrollControlled: true,
                          context: widget.parentContext!,
                          builder: (context) {
                            return CustomBottomSheet(
                              currentCalendarId: widget.currentCalendarId,
                              onEventAdded: widget.onEventAdded,
                              startTime: widget.startTime,
                              responseData: resp.data,
                              //
                            );
                          },
                        );
                      } on DioError catch (e) {
                        if (e.response?.statusCode == 422) {
                          Navigator.of(context).pop();
                          showSnackbar(
                              context, '내용에서 일정 정보를 찾지 못했어요! 다시 입력해주세요.');
                        }
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('서버와의 연결의 원활하지 않습니다.'),
                        //   ),
                        // );
                      } catch (e) {
                        Navigator.of(context).pop();
                        showSnackbar(context,
                            'An unexpected error occurred. Please try again.');
                      }

                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
    ;
  }
}
