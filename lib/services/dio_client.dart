import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/const/data.dart';

class DioClient {
  final Dio _dio = Dio();

  DioClient() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 요청 전 토큰 존재 여부 확인
        String? accessToken = await storage.read(key: ACCESS_TOKEN_KEY);
        String? refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
        if (accessToken != null || refreshToken != null) {
          options.headers['authorization'] = 'Bearer $refreshToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // 토큰 만료 시 처리
        if (error.response?.statusCode == 401) {
          try {
            Response response = await _dio.post(
                dotenv.env['BACKEND_MAIN_URL']! + '/api/v1/auth/login',
                data: {
                  'email': await storage.read(key: USER_EMAIL_KEY),
                  'password': await storage.read(key: USER_PASSWORD_KEY),
                });
            // 토큰 업데이트
            await storage.write(
                key: ACCESS_TOKEN_KEY, value: response.data['accessToken']);
            await storage.write(
                key: REFRESH_TOKEN_KEY, value: response.data['refreshToken']);
            print('토큰 갱신 완료');
            // 원래의 요청 재시도
            final cloneReq = error.requestOptions;
            cloneReq.headers['authorization'] =
                'Bearer ${response.data['accessToken']}';
            final cloneResponse = await _dio.request(
              cloneReq.path,
              options: Options(
                method: cloneReq.method,
                headers: cloneReq.headers,
              ),
              data: cloneReq.data,
              queryParameters: cloneReq.queryParameters,
            );
            return handler.resolve(cloneResponse);
          } catch (e) {
            print('토큰 갱신 실패: $e');
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    return _handleRequest(
        () async => await _dio.get(url, queryParameters: queryParameters));
  }

  Future<Response> post(String url, Map<String, dynamic> data) async {
    return _handleRequest(() async => await _dio.post(url, data: data));
  }

  Future<Response> put(String url, Map<String, dynamic> data) async {
    return _handleRequest(() async => await _dio.put(url, data: data));
  }

  Future<Response> delete(String url, {Map<String, dynamic>? data}) async {
    return _handleRequest(() async => await _dio.delete(url, data: data));
  }

  Future<Response> _handleRequest(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioError catch (e) {
      // 401 Unauthorized: 없는 계정 또는 잘못된 비밀번호
      if (e.response?.statusCode == 401) {
        throw 401;
      }

      // 422 Unprocessable Entity: 올바르지 않은 형식의 요청
      else if (e.response?.statusCode == 422) {
        throw DioError(
          response: e.response,
          requestOptions: e.requestOptions,
          type: DioErrorType.response,
        );
      }

      // 서버 응답 없음 또는 타임아웃
      else if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.receiveTimeout) {
        throw Exception('서버와의 응답이 없습니다. 잠시 후 다시 시도해 주세요.');
      }

      // 기타 에러
      else {
        throw Exception('e.response?.statusCode: ${e.response?.statusCode}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}
