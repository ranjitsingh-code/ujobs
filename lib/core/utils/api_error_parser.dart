import 'dart:convert';
import 'package:dio/dio.dart';

class ApiError {
  final String code;
  final String message;
  ApiError(this.code, this.message);
}

ApiError parseApiErrorDetail(DioException e) {
  dynamic responseData = e.response?.data;
  if (responseData is String) {
    try {
      final sanitizedString = responseData.replaceAll('\n', '\\n').replaceAll('\r', '\\r');
      responseData = jsonDecode(sanitizedString);
    } catch (_) {}
  }

  if (responseData is Map) {
    final errorField = responseData['error'];
    if (errorField is Map) {
      final code = errorField['code']?.toString() ?? '';
      final message = errorField['message']?.toString();
      
      String? detailMsg;
      final details = errorField['details'];
      if (details is Map) {
        detailMsg = details.values.expand((v) => v is List ? v : [v]).join(', ');
      }
      
      return ApiError(code, detailMsg ?? message ?? 'An unexpected error occurred.');
    } else if (errorField != null) {
      return ApiError('', errorField.toString());
    }
  }
  return ApiError('', 'A network error occurred.');
}

String parseApiError(DioException e) {
  return parseApiErrorDetail(e).message;
}
