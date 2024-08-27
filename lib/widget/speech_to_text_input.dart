import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../common/const/color.dart';
import '../common/const/data.dart';
import 'custom_bottom_sheet.dart';

class SpeechToTextInput extends StatefulWidget {
  final int? currentCalendarId;
  final Function(dynamic) onEventAdded;
  final DateTime startTime;
  final FBAuthService auth;
  final BuildContext? parentContext;

  const SpeechToTextInput({
    super.key,
    required this.auth,
    required this.currentCalendarId,
    required this.onEventAdded,
    required this.startTime,
    required this.parentContext,
  });

  @override
  State<SpeechToTextInput> createState() => _SpeechToTextInputState();
}

class _SpeechToTextInputState extends State<SpeechToTextInput> {
  final dio = Dio();
  final TextEditingController _controller =
      TextEditingController(); // TextField 컨트롤러를 추가합니다.
  String? sttText;

  bool _isListeningLoading = false; // 녹음 로딩 인디케이터 상태를 추가합니다.
  bool _isListening = false; // 녹음 상태를 추가합니다.
  final stt.SpeechToText _speechToText =
      stt.SpeechToText(); // SpeechToText 객체를 생성합니다.

  /* UI & Methods */
  void _startListening() async {
    // 녹음을 시작하는 함수입니다.
    bool available =
        await _speechToText.initialize(); // 음성 인식을 초기화하고 사용 가능한지 확인합니다.
    if (available) {
      setState(() {
        _isListening = true; // 녹음 상태를 true로 설정합니다.
        _isListeningLoading = true; // 로딩 인디케이터를 시작합니다.
      });
      _speechToText.listen(
        onResult: (result) {
          // 결과 콜백을 설정합니다.
          if (result.finalResult) {
            // 최종 결과일 때만 처리합니다.
            setState(() {
              _isListening = false; // 녹음 상태를 false로 설정합니다.
              _isListeningLoading = false; // 로딩 인디케이터를 중지합니다.
              _controller.text =
                  result.recognizedWords; // 인식된 단어를 TextField에 설정합니다.
            });
          }
        },
        localeId: 'ko_KR', // 로케일을 한국어로 설정합니다.
      );
    } else {
      setState(() {
        _isListening = false;
        _isListeningLoading = false; // 사용 불가능할 때 로딩 인디케이터를 중지합니다.
      });
    }
  }

  void _stopListening() {
    // 녹음을 중지하는 함수입니다.
    _speechToText.stop(); // 녹음을 중지합니다.
    setState(() {
      _isListening = false; // 녹음 상태를 false로 설정합니다.
      _isListeningLoading = false; // 로딩 인디케이터를 중지합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '예. 내일 10시 수강신청.',
                      ),
                      onChanged: (value) {
                        sttText = value;
                      },
                    ),
                  ),
                  if (_isListeningLoading) // 녹음 로딩 상태일 때만 표시됩니다.
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CupertinoActivityIndicator(), // 로딩 인디케이터를 표시합니다.
                    ),
                  if (!_isListeningLoading && !_controller.text.isEmpty)
                    IconButton(
                      onPressed: () async {
                        await widget.auth.checkToken();
                        var refreshToken =
                            await storage.read(key: REFRESH_TOKEN_KEY);
                        final data = {
                          'plainText': _controller.text,
                          'promptId': 1
                        };
                        final jsonData = jsonEncode(data);
                        print('STT data: $jsonData');

                        try {
                          var resp = await dio.post(
                            dotenv.env['BACKEND_AI_URL']! + '/api/v1/plainText',
                            data: jsonData,
                            options: Options(
                              headers: {
                                'authorization': 'Bearer $refreshToken',
                              },
                            ),
                          );

                          print('(STT) resp.statusCode: ${resp.statusCode}');
                          print('(STT) resp: $resp');

                          showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              barrierColor: ColorPalette.PRIMARY_COLOR[400]!
                                  .withOpacity(0.1),
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
                                );
                              });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('서버와의 연결의 원활하지 않습니다.'),
                            ),
                          );
                        }

                        // Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.send),
                    ),
                  IconButton(
                    onPressed: _isListening
                        ? _stopListening
                        : _startListening, // 녹음 상태에 따라 버튼 동작을 설정합니다.
                    icon: Icon(_isListening
                        ? Icons.mic_off
                        : Icons.mic), // 녹음 상태에 따라 아이콘을 변경합니다.
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
