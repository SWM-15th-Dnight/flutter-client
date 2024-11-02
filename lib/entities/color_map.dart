import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/const/data.dart';
import '../services/auth_service.dart';

class ColorMap{
  FBAuthService auth = FBAuthService();
  final dio = Dio();
  static Map<int, Color> ColorDict = {};

  ColorMap(){
    update();
  }

  Color get (int key) {
    if(!ColorDict.containsKey(key)) update();
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
      try{
        ColorDict[r['colorSetId']] = hexToColor(r['hexCode']);
      }
      catch(e) {} // 추가를 안하면 되므로 무시.
    }
    return;
  }
}

Color hexToColor(String input) {
  input = input.replaceAll('#', '');
  if (input.length == 6) {
    input = 'FF$input';
  }
  return Color(int.parse(input, radix: 16));
}