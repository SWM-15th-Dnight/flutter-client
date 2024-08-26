import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_client/services/auth_service.dart';

import '../common/const/data.dart';

class MainRequest {
  MainRequest();

  final dio = Dio();
  final auth = FBAuthService(); // only for checkToken()

  Future<Response?> postRequest(String path, Map<String, dynamic> data) async {
    final Response<dynamic> response =
        await dio.post(dotenv.env['BACKEND_MAIN_URL']! + path, data: data);
    print('response.statusCode ${response.statusCode}');
    print('response.data ${response.data}');
    print('response.runTimeType ${response.runtimeType}');
    print('response.data.runTimeType ${response.data.runtimeType}');
    return response;
  }

  Future<Response> getColorSet() async {
    await auth.checkToken();
    final String? accessToken = dotenv.env['ACCESS_TOKEN'];
    final String? refreshToken = dotenv.env['REFRESH_TOKEN'];

    return await dio.get(
      dotenv.env['BACKEND_MAIN_URL']! + '/colorSet/',
      options: Options(
        headers: {
          'authorization': 'Bearer $refreshToken',
        },
      ),
    );
  }

  Future<Response> deleteEvent(int eventId) async {
    await auth.checkToken();
    final String? refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    var resp = await dio.delete(
      dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/event/$eventId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      ),
    );

    return resp;
  }
}
