import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage.dart';
import 'api_endpoints.dart';

class DioClient {
  static const _base = 'https://ujobapi.gidentex.com/api/v1';

  late final Dio dio;

  DioClient(SecureStorage storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: _base,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
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
        '$_base${Ep.refresh}',
        data: {'refreshToken': refresh},
      );
      final data = res.data as Map<String, dynamic>;
      await storage.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
