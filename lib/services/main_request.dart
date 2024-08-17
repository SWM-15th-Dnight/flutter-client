import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainRequest {
  MainRequest();

  final dio = Dio();

  Future<Response?> postRequest(String path, Map<String, dynamic> data) async {
    final Response<dynamic> response =
        await dio.post(dotenv.env['BACKEND_MAIN_URL']! + path, data: data);
    print('response.statusCode ${response.statusCode}');
    print('response.data ${response.data}');
    print('response.runTimeType ${response.runtimeType}');
    print('response.data.runTimeType ${response.data.runtimeType}');
    return response;
  }
}
