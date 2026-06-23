import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class DioClient {
  late final Dio dio;

  DioClient(SecureStorage storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: Ep.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': const String.fromEnvironment('API_KEY', defaultValue: ''),
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // Inject as Cookie as well to ensure compatibility with backend cookie session guards
            options.headers['Cookie'] = 'session=$token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken(storage);
            if (refreshed) {
              final token = await storage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              try {
                final retry = await dio.fetch(error.requestOptions);
                return handler.resolve(retry);
              } catch (_) {}
            }
            // Refresh failed — clear tokens so app redirects to login
            await storage.clearAll();
          } else if (error.response?.statusCode == 500) {
            EasyLoading.showError('Server encountered an error. Please try again later.');
          } else if (error.response?.statusCode == 503) {
            EasyLoading.showError('Server is currently down for maintenance.');
          } else if (error.type == DioExceptionType.connectionTimeout || 
                     error.type == DioExceptionType.receiveTimeout || 
                     error.type == DioExceptionType.connectionError) {
            EasyLoading.showError('Unable to connect to the server. Please check your internet connection.');
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }

  Future<bool> _refreshToken(SecureStorage storage) async {
    try {
      final refresh = await storage.getRefreshToken();
      if (refresh == null) return false;
      
      final res = await Dio().post(
        '${Ep.baseUrl}${Ep.refresh}',
        options: Options(
          headers: {
            'X-Api-Key': const String.fromEnvironment('API_KEY', defaultValue: ''),
            // Pass the refresh token in the Cookie header as the API expects
            'Cookie': 'refreshToken=$refresh', 
          },
        ),
      );
      final data = res.data as Map<String, dynamic>;
      final responseData = data['data'] ?? data;
      
      await storage.saveTokens(
        responseData['accessToken'] as String,
        responseData['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
