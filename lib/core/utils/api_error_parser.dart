import 'dart:convert';
import 'package:dio/dio.dart';

class ApiError {
  final String code;
  final String message;
  ApiError(this.code, this.message);
}

String? extractApiMessage(dynamic responseData) {
  dynamic data = responseData;
  if (data is String) {
    try {
      final sanitizedString = data
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');
      data = jsonDecode(sanitizedString);
    } catch (_) {
      return null;
    }
  }

  if (data is! Map) return null;

  final topLevelMessage = data['message']?.toString().trim();
  if (topLevelMessage != null && topLevelMessage.isNotEmpty) {
    return topLevelMessage;
  }

  final errorField = data['error'];
  if (errorField is Map) {
    final errorMessage = errorField['message']?.toString().trim();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }
  }

  final nestedData = data['data'];
  if (nestedData is Map) {
    final nestedMessage = nestedData['message']?.toString().trim();
    if (nestedMessage != null && nestedMessage.isNotEmpty) {
      return nestedMessage;
    }
  }

  return null;
}

ApiError parseApiErrorDetail(DioException e) {
  dynamic responseData = e.response?.data;
  if (responseData is String) {
    try {
      final sanitizedString = responseData
          .replaceAll('\n', '\\n')
          .replaceAll('\r', '\\r');
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
        detailMsg = details.values
            .expand((v) => v is List ? v : [v])
            .join(', ');
      }

      return ApiError(
        code,
        detailMsg ?? message ?? 'An unexpected error occurred.',
      );
    } else if (errorField != null) {
      return ApiError('', errorField.toString());
    }
    final topLevelMessage = responseData['message']?.toString();
    if (topLevelMessage != null && topLevelMessage.isNotEmpty) {
      return ApiError('', topLevelMessage);
    }
  }
  return ApiError('', 'A network error occurred.');
}

String parseApiError(DioException e) {
  return parseApiErrorDetail(e).message;
}
