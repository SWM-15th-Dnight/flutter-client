import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_client/common/component/custom_app_bar.dart';
import 'package:mobile_client/common/component/custom_divider.dart';
import 'package:mobile_client/common/component/plan_badge.dart';
import 'package:mobile_client/common/component/setting_tile.dart';
import 'package:mobile_client/entities/calendar.dart';
import 'package:mobile_client/screens/signIn/sign_in_view.dart';
import 'package:mobile_client/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/component/header_text.dart';
import '../../common/component/snackbar_helper.dart';
import '../../common/const/color.dart';
import '../../common/const/data.dart';
import '../../entities/user.dart';
import '../root/root_view.dart';

class PreferenceView extends StatefulWidget {
  final FBAuthService auth;
  String? displayName = '이것은 이름입니다.';
  final Calendar currentCalendar;
  final Function? onCalendarModified;
  // TODO. FCM test
  static const route = '/preference';

  PreferenceView({
    super.key,
    required this.auth,
    required this.currentCalendar,
    required this.onCalendarModified,
  });

  @override
  State<PreferenceView> createState() => _PreferenceViewState();
}

class _PreferenceViewState extends State<PreferenceView> {
  File? image;
  final picker = ImagePicker();
  final TextEditingController displayNameController = TextEditingController();
  bool isEditing = false;

  // for modify calendar info, import/export ics file
  final FBAuthService auth = FBAuthService();
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadImage();
    _loadDisplayName();
  }

  Future<void> _pickImage() async {
    print('pick image');
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final fileName = 'profile_image.png';
      final File localImage =
          await File(pickedFile.path).copy('$path/$fileName');

      setState(() {
        image = localImage;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('profile_image_path')) {
        prefs.remove('profile_image_path');
      }
      prefs.setString('profile_image_path', localImage.path);

      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_path');

    if (imagePath != null) {
      setState(() {
        image = File(imagePath);
      });
    }
  }

  Future<void> _loadDisplayName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.displayName = prefs.getString('display_name') ?? '이것은 이름입니다.';
    setState(() {
      displayNameController.text = widget.displayName!;
    });
  }

  Future<void> _updateDisplayName() async {
    print('onTap: update display name');
    if (isEditing) {
      final newName = displayNameController.text;
      if (newName.isNotEmpty) {
        widget.auth.getCurrentUser()?.updateDisplayName(newName);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('display_name', newName);
        setState(() {
          widget.displayName = newName;
          print('수정된 이름: ${widget.displayName}');
          isEditing = false;
        });
      }
    } else {
      setState(() {
        isEditing = true;
      });
    }
  }

  void _showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text('로그아웃'),
      content: Text('로그아웃 하시면 Calinify의 일정 알림을 받으실 수 없습니다.'),
      actions: <Widget>[
        CancelButton(),
        AcceptButton(
          text: '로그아웃',
          onPressed: widget.auth.signOut(),
          navigator: RootView(auth: widget.auth),
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double photoLength = 100.0;
    // TODO. use shared preference before using local DB
    return Scaffold(
      backgroundColor: ColorPalette.GRAY_COLOR[50]!,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              // Appbar
              CustomAppBar(
                leftWidget: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                centerContent: '프로필 및 설정',
                // TODO. show popup with 'logout' button
                rightWidget: PopupMenuButton<int>(
                  icon: Icon(Icons.more_horiz),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  onSelected: (int value) {
                    if (value == 1) {
                      _showAlertDialog(context);
                    }
                    // TODO. show alert dialog for '회원탈퇴'
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 1,
                      height: 32.0,
                      child: Center(
                          child: Text(
                        '로그아웃',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 2,
                      height: 32.0,
                      child: Center(
                          child: Text(
                        '회원탈퇴',
                        style: TextStyle(
                          color: ColorPalette.ERROR_COLOR[400]!,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                    ),
                  ],
                ),
              ),
              // Profile summary
              Padding(
                padding: const EdgeInsets.only(
                  top: 32.0,
                  bottom: 12.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(161616.0),
                        child: image != null
                            ? Image.file(
                                image!,
                                width: photoLength,
                                height: photoLength,
                                fit: BoxFit.cover,
                              )
                            : widget.auth.getCurrentUser()?.photoURL != null
                                ? Image.network(
                                    widget.auth.getCurrentUser()!.photoURL!,
                                    width: photoLength,
                                    height: photoLength,
                                    fit: BoxFit.cover,
                                  )
                                : Stack(
                                    children: [
                                      Container(
                                        width: photoLength,
                                        height: photoLength,
                                        color: Colors.grey,
                                      ),
                                      Image.asset(
                                        'asset/img/user/default_account_profile.png',
                                        width: photoLength,
                                        height: photoLength,
                                        fit: BoxFit.cover,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            isEditing
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    child: TextField(
                                      controller: displayNameController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: '보여질 이름을 알려주세요!',
                                      ),
                                    ),
                                  )
                                : Text(
                                    widget.displayName!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _updateDisplayName,
                              child: Icon(
                                isEditing ? Icons.check : Icons.edit,
                                size: 20,
                                //color: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PlanBadge(tier: 'Basic'),
                            SizedBox(width: 8),
                            Text(
                              '2024. 10. 1 ~ 11. 1',
                              style: TextStyle(
                                color: ColorPalette.GRAY_COLOR[400]!,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: ColorPalette.GRAY_COLOR[400]!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Preference list
              Container(
                color: ColorPalette.GRAY_COLOR[100]!,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Column(
                    children: [
                      // TODO. split Preference list widget
                      SettingTile(
                        titleText: '현재 선택된 캘린더',
                        trailingText: widget.currentCalendar.title,
                        onTapEvent: () => _showEditCalendarTitleDialog(context),
                      ),
                      SizedBox(height: 8.0),
                      // TODO. show file picker
                      SettingTile(
                        titleText: '일정 불러오기',
                        onTapEvent: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['ics'],
                          );

                          if (result != null) {
                            //File file = File(result.files.single.path!);
                            PlatformFile file = result.files.first;

                            const int MAX_FILE_SIZE = 5 * 1024 * 1024;

                            if (file.extension != 'ics') {
                              showSnackbar(context, '올바른 ics 파일 형식이 아닙니다.');
                              return;
                            }

                            if (file.size > MAX_FILE_SIZE) {
                              showSnackbar(context, '파일 크기는 5MB를 넘을 수 없습니다.');
                              return;
                            }

                            try {
                              await auth.checkToken();
                              var refreshToken =
                                  await storage.read(key: REFRESH_TOKEN_KEY);

                              FormData formData = FormData.fromMap({
                                // TODO. use /api/v1/user/
                                'user_id': dotenv.env['USER_ID']!,
                                'ics_file': await MultipartFile.fromFile(
                                  file.path!,
                                  filename: file.name,
                                ),
                              });

                              Response response = await dio.post(
                                dotenv.env['BACKEND_TRANSPORT_URL']! +
                                    '/api/v1/import',
                                data: formData,
                                options: Options(headers: {
                                  'Content-Type': 'multipart/form-data',
                                  'authorization': 'Bearer $refreshToken',
                                }),
                              );

                              // 응답 확인
                              print('응답 코드: ${response.statusCode}');
                              print('응답 데이터: ${response.data}');

                              if (response.statusCode == 200) {
                                print('파일 업로드 성공');
                              }
                            } on DioError catch (e) {
                              // DioError의 응답 코드 및 메시지 확인
                              if (e.response != null) {
                                print(
                                    'DioError 응답 코드: ${e.response?.statusCode}');
                                print('DioError 응답 데이터: ${e.response?.data}');
                              } else {
                                print('DioError 메시지: ${e.message}');
                              }

                              // 422 Unprocessable Entity: 올바르지 않은 형식의 요청
                              if (e.response?.statusCode == 422) {
                                showSnackbar(context, '올바른 형식이 아닙니다.');
                              }

                              // 서버 응답 없음 또는 타임아웃
                              else if (e.type == DioErrorType.connectTimeout ||
                                  e.type == DioErrorType.receiveTimeout) {
                                showSnackbar(
                                    context, '서버와의 응답이 없습니다. 잠시 후 다시 시도해 주세요.');
                              }

                              // 기타 에러
                              else {
                                showSnackbar(context, '잠시후 다시 시도해 주세요.');
                              }
                            } catch (e) {
                              // 예상하지 못한 예외 처리
                              showSnackbar(context, '파일 업로드 중 오류가 발생했습니다.');
                            }

                            showSnackbar(context, '파일 크기 : ${file.size} bytes');
                          }
                        },
                      ),
                      CustomDivider(),
                      SettingTile(titleText: '일정 내보내기'),
                      CustomDivider(),
                      SettingTile(titleText: '이것은 설정입니다.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCalendarTitleDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('캘린더 이름 바꾸기'),
          content: TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: '새 캘린더',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (_titleController.text == '') {
                  Navigator.of(context).pop();
                  showSnackbar(context, '변경할 캘린더 이름을 입력하세요.');
                  return;
                }

                _updateCalendarTitle(_titleController.text);
                _modifyCalendarTitle(_titleController.text);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _updateCalendarTitle(String newTitle) {
    setState(() {
      widget.currentCalendar.title = newTitle;
    });
  }

  Future<void> _modifyCalendarTitle(String title) async {
    await widget.auth.checkToken();
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    var data = {
      "calendarId": widget.currentCalendar.id,
      "title": title,
      "description": widget.currentCalendar.id,
      "timezoneId": "Asia/Seoul",
      "colorSetId": 1,
      "isDeleted": 0,
      "deleted": 0,
    };
    var resp = await dio.put(
      dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/calendars/',
      data: data,
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    print('캘린더 수정 ${resp.statusCode}');
    print('캘린더 수정 ${resp.data}');

    Navigator.of(context).pop();

    // getCalendarList() at MainCalendar
    if (widget.onCalendarModified != null) {
      widget.onCalendarModified!();
    }
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        '취소',
      ),
    );
  }
}

class AcceptButton extends StatelessWidget {
  final String text;
  final Future<void> onPressed;
  final Widget navigator;

  const AcceptButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.navigator,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => navigator),
        );
        //await onPressed;
      },
      child: Text(
        text,
      ),
    );
  }
}
