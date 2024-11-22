import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_client/common/component/custom_divider.dart';
import 'package:mobile_client/common/component/snackbar_helper.dart';
import 'package:mobile_client/screens/calendar/form_bottom_sheet.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:mobile_client/services/dio_client.dart';
import 'package:mobile_client/widget/custom_bottom_sheet.dart';
import 'package:mobile_client/widget/custom_modal_bottom_sheet.dart';
import 'package:mobile_client/widget/plain_text_input.dart';
import 'package:mobile_client/widget/speech_to_text_input.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

import '../common/component/loading_indicators.dart';
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

  File resizeImage(File originalImage) {
    // 이미지 읽기
    final image = img.decodeImage(originalImage.readAsBytesSync());

    // 이미지 크기 조정 (예: 가로 800px로 축소)
    final resized = img.copyResize(image!, width: 800);

    // 임시 파일로 저장
    final resizedFile = File('${originalImage.path}_resized.jpg')
      ..writeAsBytesSync(img.encodeJpg(resized));

    return resizedFile;
  }

  Future<void> _handleImageUpload(
    BuildContext context,
    ImageSource source,
  ) async {
    /*
    if (source == ImageSource.camera &&
        !(await Permission.camera.request().isGranted)) {
      showSnackbar(context, '카메라 권한이 필요합니다.');
      return;
    }

    if (source == ImageSource.gallery &&
        !(await Permission.photos.request().isGranted)) {
      showSnackbar(context, '갤러리 권한이 필요합니다.');
      return;
    }*/

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.10),
        builder: (BuildContext dialogContext) {
          return Center(
            child: Container(
              child: LoadingIndicators(
                color: ColorPalette.PRIMARY_COLOR[400]!,
              ),
            ),
          );
        },
      );

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        // 이미지 크기 조정
        imageFile = resizeImage(imageFile);

        // TODO.
        int promptId = 1;
        int inputType = 3; // 3: 이미지

        FormData formData = FormData.fromMap({
          'promptId': promptId,
          'inputType': inputType,
          'file': await MultipartFile.fromFile(
            imageFile.path,
            filename: 'selected_image.jpg',
          ),
        });

        try {
          await auth.checkToken();
          final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
          Response response = await Dio().post(
            '${dotenv.env['BACKEND_MAIN_URL']!}/api/v1/eventProcessing/imageProcessing',
            data: formData,
            options: Options(headers: {
              'authorization': 'Bearer $refreshToken',
              'Content-Type': 'multipart/form-data',
            }),
          );

          if (response.statusCode == 200) {
            print('이미지 업로드 성공: ${response.data}');
            //onEventAdded(response.data);

            // Hide loading indicator
            Navigator.of(context).pop();

            showModalBottomSheet(
                backgroundColor: Colors.transparent,
                barrierColor: ColorPalette.PRIMARY_COLOR[400]!.withOpacity(0.1),
                useSafeArea: true,
                // TODO. 폼에 입력된 정보가 있을 경우, 경고창 띄우기
                isDismissible: true,
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return CustomBottomSheet(
                    currentCalendarId: currentCalendarId,
                    onEventAdded: onEventAdded,
                    startTime: DateTime.now(),
                    responseData: response.data,
                  );
                });
          } else {
            print('이미지 업로드 실패: ${response.data}');
            showSnackbar(context, '이미지 업로드 중 오류가 발생했습니다.');
            // Hide loading indicator
            Navigator.of(context).pop();
          }
        } on DioError catch (e) {
          print('이미지 업로드 실패: $e');
          print('이미지 업로드 실패: ${e.response}');
          print('이미지 업로드 실패: ${e.response?.data}');
          print('이미지 업로드 실패: ${e.response?.statusCode}');

          if (e.response?.statusCode == 422) {
            showSnackbar(context, '일정 데이터 포착 실패, 다시 시도해주세요.');
          } else {
            showSnackbar(context, '이미지 업로드 중 오류가 발생했습니다.');
          }

          // Hide loading indicator
          Navigator.of(context).pop();
        }
      } else {
        print('이미지 선택 취소');
        // Hide loading indicator
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();
    }
  }

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
            shape: CircleBorder(),
            child: const Icon(
              Icons.text_fields,
              color: Colors.white,
            ),
            label: '문장 입력',
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
              Icons.image,
              color: Colors.white,
            ),
            label: '이미지 등록',
            backgroundColor: ColorPalette.PRIMARY_COLOR[400]!,
            onTap: () {
              // TODO. 이미지 등록 기능 추가
              CustomModalBottomSheet(
                context: context,
                customHeight: MediaQuery.of(context).size.height * 0.24,
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '이미지로 일정 등록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              await _handleImageUpload(
                                  context, ImageSource.gallery);
                            },
                            child: Container(
                              color: ColorPalette.GRAY_COLOR[50]!,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 52,
                                child: Center(
                                  child: Text(
                                    '갤러리에서 선택',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CustomDivider(),
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              await _handleImageUpload(
                                  context, ImageSource.camera);
                            },
                            child: Container(
                              color: ColorPalette.GRAY_COLOR[50]!,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                height: 52,
                                child: Center(
                                  child: Text(
                                    '카메라로 촬영',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          ),
          SpeedDialChild(
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(161616.0),
            // ),
            shape: CircleBorder(),
            child: const Icon(Icons.edit, // arrow_circle_down_rounded,
                color: Colors.white),
            label: '일정 직접 입력',
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
        ],
      ),
    );
  }
}
