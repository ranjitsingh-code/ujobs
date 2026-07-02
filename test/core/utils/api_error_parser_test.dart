import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ujobs_app/core/utils/api_error_parser.dart';

DioException _makeError({dynamic data, int status = 400}) => DioException(
      requestOptions: RequestOptions(path: '/test'),
      response: Response(
        data: data,
        statusCode: status,
        requestOptions: RequestOptions(path: '/test'),
      ),
    );

void main() {
  group('extractApiMessage', () {
    test('returns top-level message', () {
      expect(
        extractApiMessage({'message': 'Email already exists'}),
        'Email already exists',
      );
    });

    test('returns error.message when no top-level message', () {
      expect(
        extractApiMessage({'error': {'message': 'Invalid token'}}),
        'Invalid token',
      );
    });

    test('returns data.message when nested', () {
      expect(
        extractApiMessage({'data': {'message': 'Not found'}}),
        'Not found',
      );
    });

    test('returns null for unrecognised shape', () {
      expect(extractApiMessage({'foo': 'bar'}), isNull);
    });

    test('returns null for non-map input', () {
      expect(extractApiMessage(42), isNull);
    });

    test('parses JSON string input', () {
      expect(
        extractApiMessage('{"message":"Parsed from string"}'),
        'Parsed from string',
      );
    });
  });

  group('parseApiErrorDetail', () {
    test('extracts error.code and error.message', () {
      final err = _makeError(data: {
        'error': {'code': 'AUTH_001', 'message': 'Unauthorised'},
      });
      final result = parseApiErrorDetail(err);
      expect(result.code, 'AUTH_001');
      expect(result.message, 'Unauthorised');
    });

    test('flattens error.details into message', () {
      final err = _makeError(data: {
        'error': {
          'code': 'VALIDATION',
          'message': 'Validation failed',
          'details': {'email': ['Required'], 'password': ['Too short']},
        },
      });
      final result = parseApiErrorDetail(err);
      expect(result.message, contains('Required'));
      expect(result.message, contains('Too short'));
    });

    test('falls back to top-level message', () {
      final err = _makeError(data: {'message': 'Something went wrong'});
      expect(parseApiErrorDetail(err).message, 'Something went wrong');
    });

    test('returns network error when no response data', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      expect(parseApiErrorDetail(err).message, 'A network error occurred.');
    });

    test('handles HTML 413 body gracefully', () {
      final err = _makeError(
        data: '<html><head><title>413 Request Entity Too Large</title></head></html>',
        status: 413,
      );
      // Should not throw; returns fallback
      expect(parseApiErrorDetail(err).message, isNotEmpty);
    });
  });

  group('parseApiError', () {
    test('returns message string directly', () {
      final err = _makeError(data: {'message': 'Quick test'});
      expect(parseApiError(err), 'Quick test');
    });
  });
}
