import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._();

  static const Duration timeout = Duration(seconds: 30);

  static Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p').replace(queryParameters: query);
  }

  static String _extractError(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map) {
        final d = body['detail'];
        if (d is String) return d;
        if (d is List && d.isNotEmpty) {
          final first = d.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
        }
      }
    } catch (_) {}
    return 'Erreur HTTP ${res.statusCode}';
  }

  static void _check(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ApiException(
      _extractError(res),
      statusCode: res.statusCode,
      detail: res.body,
    );
  }

  static dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final res = await http
        .get(_uri(path, query), headers: ApiConfig.jsonHeaders(withAuth: auth))
        .timeout(timeout);
    _check(res);
    return _decode(res);
  }

  static Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
  }) async {
    final res = await http
        .post(
          _uri(path),
          headers: ApiConfig.jsonHeaders(withAuth: auth),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    _check(res);
    return _decode(res);
  }

  static Future<dynamic> put(
    String path, {
    required Map<String, dynamic> body,
    bool auth = true,
  }) async {
    final res = await http
        .put(
          _uri(path),
          headers: ApiConfig.jsonHeaders(withAuth: auth),
          body: jsonEncode(body),
        )
        .timeout(timeout);
    _check(res);
    return _decode(res);
  }

  static Future<dynamic> delete(String path, {bool auth = true}) async {
    final res = await http
        .delete(_uri(path), headers: ApiConfig.jsonHeaders(withAuth: auth))
        .timeout(timeout);
    _check(res);
    return _decode(res);
  }

  static Future<dynamic> postMultipart(
    String path, {
    required String fileField,
    required String filePath,
    Map<String, String> fields = const {},
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(ApiConfig.authHeadersOnly());
    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

    final streamed = await request.send().timeout(timeout);
    final res = await http.Response.fromStream(streamed);
    _check(res);
    return _decode(res);
  }

  static Future<List<int>> getBytes(String path, {bool auth = true}) async {
    final res = await http
        .get(_uri(path), headers: ApiConfig.authHeadersOnly())
        .timeout(timeout);
    _check(res);
    return res.bodyBytes;
  }
}
