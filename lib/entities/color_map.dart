import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/const/data.dart';
import '../services/auth_service.dart';

class ColorMap{
  FBAuthService auth = FBAuthService();
  final dio = Dio();
  Map<int, Color> ColorDict = {};

  ColorMap(){
    update();
  }

  Color get(int key){
    if(ColorDict[key] == null) update();
    return ColorDict[key] ?? hexToColor("#ffffff"); // fallback 나중에 수정해야할듯
  }

  Future<void> update() async{
    print('updating CalendarColorMap()');

    await auth.checkToken();
    var refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    print('refreshToken: $refreshToken');

    var resp = await dio.get(
      dotenv.env['BACKEND_MAIN_URL']! + '/colorSet/',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );

    for (var r in resp.data) {
      ColorDict[r['colorSetId']] = hexToColor(r['hexCode']);
    }
    print("ColorDict");
    print(ColorDict);
    return;
  }
}

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}