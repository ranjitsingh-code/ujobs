import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const _reset   = '\x1B[0m';
const _bold    = '\x1B[1m';
const _cyan    = '\x1B[36m';
const _orange  = '\x1B[38;5;214m';
const _green   = '\x1B[32m';
const _red     = '\x1B[31m';
const _gray    = '\x1B[90m';
const _white   = '\x1B[97m';
const _yellow  = '\x1B[33m';
const _magenta = '\x1B[35m';
const _blue    = '\x1B[34m';

String _methodColor(String method) => switch (method) {
      'GET'    => _cyan,
      'POST'   => _yellow,
      'PUT'    => _blue,
      'PATCH'  => _magenta,
      'DELETE' => _red,
      _        => _white,
    };

String _statusColor(int status) {
  if (status >= 500) return _red;
  if (status >= 400) return _orange;
  if (status >= 300) return _yellow;
  return _green;
}

class ColoredDioLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final m = options.method.toUpperCase();
      final mc = _methodColor(m);
      final url = options.uri.toString();
      _p('$_bold$_cyan┌── 🌐 $mc$m$_reset$_cyan  $_white$url$_reset');
      _logHeaders(options.headers);
      if (options.data != null) {
        _p('$_cyan│$_reset  $_bold${_orange}Body:$_reset');
        _logBody(options.data, _orange);
      }
      _p('$_cyan└────────────────────────────$_reset');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final status = response.statusCode ?? 0;
      final sc = _statusColor(status);
      final ms = _elapsed(response.requestOptions);
      final m = response.requestOptions.method.toUpperCase();
      final mc = _methodColor(m);
      final url = response.requestOptions.uri.toString();
      _p('$_bold$_green┌── ✅ $sc$status$_reset$_green  $mc$m$_reset$_green  $_white$url$_reset  $_gray${ms}ms$_reset');
      _p('$_green│$_reset  $_bold${_green}Body:$_reset');
      _logBody(response.data, _green);
      _p('$_green└────────────────────────────$_reset');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final status = err.response?.statusCode ?? 0;
      final sc = status > 0 ? _statusColor(status) : _red;
      final ms = _elapsed(err.requestOptions);
      final m = err.requestOptions.method.toUpperCase();
      final mc = _methodColor(m);
      final url = err.requestOptions.uri.toString();
      _p('$_bold$_red┌── ❌ $sc$status$_reset$_red  $mc$m$_reset$_red  $_white$url$_reset  $_gray${ms}ms$_reset');
      _p('$_red│$_reset  $_bold${_red}Type:$_reset  $_orange${err.type.name}$_reset');
      if (err.response?.data != null) {
        _p('$_red│$_reset  $_bold${_red}Body:$_reset');
        _logBody(err.response!.data, _red);
      } else if (err.message != null) {
        _p('$_red│$_reset  $_bold${_red}Message:$_reset  $_white${err.message}$_reset');
      }
      _p('$_red└────────────────────────────$_reset');
    }
    handler.next(err);
  }

  void _logHeaders(Map<String, dynamic> headers) {
    final safe = Map<String, dynamic>.from(headers)
      ..remove('Authorization')
      ..remove('X-Api-Key');
    if (safe.isNotEmpty) {
      _p('$_cyan│$_reset  $_bold${_gray}Headers:$_reset  $_gray$safe$_reset');
    }
  }

  void _logBody(dynamic data, String color) {
    final str = data?.toString() ?? 'null';
    const chunkSize = 800;
    for (var i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      _p('$color│  ${str.substring(i, end)}$_reset');
    }
  }

  int _elapsed(RequestOptions options) {
    final t = options.extra['_startTime'];
    if (t is DateTime) return DateTime.now().difference(t).inMilliseconds;
    return 0;
  }

  void _p(String msg) => debugPrint(msg);
}

class _TimestampInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startTime'] = DateTime.now();
    handler.next(options);
  }
}

final timestampInterceptor = _TimestampInterceptor();
