import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/const/data.dart';
import '../services/auth_service.dart';

class ColorMap{
  FBAuthService auth = FBAuthService();
  final dio = Dio();
  static Map<int, Color> ColorDict = {};

  ColorMap();

  Future<Color> get (int key) async {
    if(!ColorDict.containsKey(key)) await update();
    return ColorDict[key] ?? hexToColor("#ffffff"); // fallback 나중에 수정해야할듯
  }

  List<Color> getTotal(){
    if(ColorDict.isEmpty) update();
    List<Color> ret = [];
    for(var elem in ColorDict.values){
      ret.add(elem);
    }
    return ret;
  }

  Future<void> update() async{
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
    return;
  }
}

Color hexToColor(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}