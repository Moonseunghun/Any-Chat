import 'package:dio/dio.dart';

import '../model/auth.dart';
import './error.dart';
import 'config.dart';

class HttpClient {
  final Dio dio = Dio();
  final String baseUrl = HttpConfig.prodUrl;

  HttpClient();

  Future<T> createRequest<T>(Future<T> Function() request) => request.call();

  Map<String, dynamic> optionsHeader() => {'Content-Type': 'application/json'};

  Future<T> get<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.get('$baseUrl$path',
              queryParameters: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> post<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.post('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> put<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? body}) =>
      createRequest(request(converter ?? (data) => data as T,
          () => dio.put('$baseUrl$path', data: body, options: Options(headers: optionsHeader()))));

  Future<T> patch<T>(
          {required String path,
          T Function(Map<String, dynamic>)? converter,
          Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          converter ?? (data) => data as T,
          () => dio.patch('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> delete<T>({required String path, Map<String, dynamic>? queryParams}) =>
      createRequest(request(
          (data) => data as T,
          () => dio.delete('$baseUrl$path',
              data: queryParams, options: Options(headers: optionsHeader()))));

  Future<T> Function() request<T>(
          T Function(Map<String, dynamic>) converter, Future<Response> Function() handler) =>
      () => handler().then((result) => converter(result.data)).catchError((error, stackTrace) =>
          error is DioException
              ? throw Error(error, stackTrace: stackTrace, statusCode: error.response?.statusCode)
              : throw Error(error, stackTrace: stackTrace));
}

class SecuredHttpClient extends HttpClient {
  SecuredHttpClient();

  @override
  Map<String, dynamic> optionsHeader() => {
        'Content-Type': 'application/json',
        if (auth != null) 'Authorization': 'Bearer ${auth!.accessToken}'
      };

  // FIXME: Token 유효성 검사 실패 시, Refresh Token을 이용하여 재발급하는 로직 추가 필요
  @override
  Future<T> createRequest<T>(Future<T> Function() request) => request.call();
}
