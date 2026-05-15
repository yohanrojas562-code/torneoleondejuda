import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging interceptor que solo loguea en modo debug. En release queda
/// completamente silencioso (cero overhead). Pretty-printea JSON y enmascara
/// headers sensibles para no exponer tokens en logs accidentalmente.
class LoggingInterceptor extends Interceptor {
  static const _sensitiveHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
    'x-csrf-token',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      _log(
        '➡️  ${options.method} ${options.uri}',
        headers: options.headers,
        body: options.data,
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final method = response.requestOptions.method;
      final uri = response.requestOptions.uri;
      _log(
        '✅ ${response.statusCode} $method $uri',
        body: response.data,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final method = err.requestOptions.method;
      final uri = err.requestOptions.uri;
      final status = err.response?.statusCode ?? 0;
      _log(
        '❌ $status $method $uri',
        body: err.response?.data ?? err.message,
      );
    }
    handler.next(err);
  }

  void _log(
    String title, {
    Map<String, dynamic>? headers,
    Object? body,
  }) {
    final buffer = StringBuffer()..writeln(title);
    if (headers != null && headers.isNotEmpty) {
      final masked = <String, Object?>{};
      headers.forEach((k, v) {
        masked[k] = _sensitiveHeaders.contains(k.toLowerCase()) ? '***' : v;
      });
      buffer.writeln('   headers: ${_pretty(masked)}');
    }
    if (body != null) {
      buffer.writeln('   body: ${_pretty(body)}');
    }
    developer.log(buffer.toString().trimRight(), name: 'API');
  }

  String _pretty(Object? data) {
    if (data == null) return 'null';
    if (data is FormData) {
      return 'FormData(${data.fields.length} fields, ${data.files.length} files)';
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } on Object {
      return data.toString();
    }
  }
}
