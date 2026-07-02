import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_endpoints.dart';
import '../providers/role_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  late final Dio dio;

  DioClient(Ref ref) {
    final storage = ref.read(secureStorageProvider);
    dio = Dio(
      BaseOptions(
        baseUrl: Ep.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
        headers: {
          'X-Api-Key': const String.fromEnvironment('API_KEY', defaultValue: 'jp_56a375680eef542027dc87979dee0f8c0e6c79940bdac564d21f48457d904ccc'),
        },
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
            await storage.clearAll();
          } else if (error.response?.statusCode == 500) {
            EasyLoading.showError('Server encountered an error. Please try again later.');
          } else if (error.response?.statusCode == 503) {
            EasyLoading.showError('Server is currently down for maintenance.');
          } else if (error.type == DioExceptionType.connectionTimeout || 
                     error.type == DioExceptionType.receiveTimeout || 
                     error.type == DioExceptionType.connectionError) {
            EasyLoading.showError('Unable to connect to the server. Please check your internet connection.');
          } else if (error.response?.statusCode == 413) {
            EasyLoading.showError('File is too large. Please upload a smaller file.');
          } else if (error.response?.statusCode == 423) {
            // Let the API caller handle the 423 Locked response
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

}
