import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'token_store.dart';

const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl {
  if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
  return !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? 'http://10.0.2.2:8081/api/v1'
      : 'http://localhost:8081/api/v1';
}

final class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

final class ApiClient {
  ApiClient({required TokenStore tokenStore, http.Client? client})
    : _tokenStore = tokenStore,
      _client = client ?? http.Client(),
      _baseUri = Uri.parse(
        apiBaseUrl.endsWith('/') ? apiBaseUrl : '$apiBaseUrl/',
      );

  final TokenStore _tokenStore;
  final http.Client _client;
  final Uri _baseUri;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);
  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);
  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);
  Future<void> delete(String path) async {
    await _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
  }) async {
    final uri = _baseUri.resolve(path).replace(queryParameters: query);
    final token = await _tokenStore.readToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (token != null && token.isNotEmpty)
      headers['Authorization'] = 'Bearer $token';
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 204 || response.bodyBytes.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Could not connect to the server. Check your connection and API address.',
      );
    } on FormatException {
      throw const ApiException(
        'The server returned a response the app could not read.',
      );
    }
  }

  String _errorMessage(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) {
        final detail = payload['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } on FormatException {
      // Fall through to a stable, user-safe message.
    }
    return switch (response.statusCode) {
      401 => 'Your session expired. Sign in again.',
      403 => 'You do not have permission to do that.',
      404 => 'That job application could not be found.',
      409 => 'This record changed. Refresh it and try again.',
      422 => 'Some of the information needs attention.',
      >= 500 => 'The service is having trouble. Try again shortly.',
      _ => 'The request could not be completed. (${response.statusCode})',
    };
  }

  void close() => _client.close();
}
