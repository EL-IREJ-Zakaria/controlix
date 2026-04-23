import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/connection_config.dart';
import '../error/app_exception.dart';

class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  Future<Map<String, dynamic>> get(ConnectionConfig config, String path) async {
    return _send(
      () => _client.get(_uri(config, path), headers: _headers(config)),
    );
  }

  Future<Map<String, dynamic>> post(
    ConnectionConfig config,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send(
      () => _client.post(
        _uri(config, path),
        headers: _headers(config),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    ConnectionConfig config,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send(
      () => _client.put(
        _uri(config, path),
        headers: _headers(config),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    ConnectionConfig config,
    String path,
  ) async {
    return _send(
      () => _client.delete(_uri(config, path), headers: _headers(config)),
    );
  }

  Uri _uri(ConnectionConfig config, String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${config.baseUrl}$normalizedPath');
  }

  Map<String, String> _headers(ConnectionConfig config) {
    return <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Controlix-Key': config.secretKey,
    };
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(const Duration(seconds: 12));
      final payload = _decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return payload;
      }

      final message = _extractErrorMessage(payload);
      throw AppException(
        message ?? 'Request failed.',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const AppException(
        'The request timed out. Verify that the Windows agent is running and reachable on your LAN.',
      );
    } on FormatException {
      throw const AppException(
        'The Windows agent returned an invalid response.',
      );
    } on http.ClientException catch (error) {
      throw AppException(error.message);
    }
  }

  String? _extractErrorMessage(Map<String, dynamic> payload) {
    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    if (message is Map<String, dynamic>) {
      final nested = message['content'];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested;
      }
    }

    final error = payload['error'];
    if (error is Map<String, dynamic>) {
      final nested = error['message'];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested;
      }
    }

    if (message != null) {
      return message.toString();
    }
    if (error != null) {
      return error.toString();
    }
    return null;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('The API response is not a JSON object.');
  }
}
