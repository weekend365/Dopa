import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DiaryFailure implements Exception {
  const DiaryFailure(this.code);
  final String code;
}

abstract class DiaryApi {
  bool get configured;
  Future<bool> available();
  Future<void> consent();
  Future<String> submit(String id, Uint8List photo);
  Future<String> status(String id);
  Future<Uint8List> image(String id);
  Future<void> acknowledge(String id);
  Future<void> delete(String id);
  Future<void> deleteSession();
}

class HttpDiaryApi implements DiaryApi {
  HttpDiaryApi(this.baseUrl, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();
  final String baseUrl;
  final FlutterSecureStorage _storage;
  String get _key => 'diary-session-${sha256.convert(utf8.encode(baseUrl))}';
  @override
  bool get configured => baseUrl.isNotEmpty;

  Future<Uint8List> _request(
    String method,
    String path, {
    Uint8List? bytes,
    Map<String, Object>? json,
    bool anonymous = false,
  }) async {
    if (!configured) throw const DiaryFailure('not_configured');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .openUrl(method, Uri.parse('$baseUrl/v1$path'))
          .timeout(const Duration(seconds: 10));
      if (!anonymous) {
        final token = await _storage.read(key: _key);
        if (token == null) throw const DiaryFailure('unauthorized');
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (bytes != null) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'image/png');
        request.add(bytes);
      } else if (json != null) {
        request.headers.contentType = ContentType.json;
        request.add(utf8.encode(jsonEncode(json)));
      }
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response.timeout(const Duration(seconds: 15))) {
        if (builder.length + chunk.length > 18 * 1024 * 1024) {
          throw const DiaryFailure('too_large');
        }
        builder.add(chunk);
      }
      final result = builder.takeBytes();
      if (response.statusCode >= 400) {
        final decoded = jsonDecode(utf8.decode(result)) as Map<String, dynamic>;
        throw DiaryFailure(decoded['code'] as String? ?? 'network');
      }
      return result;
    } on DiaryFailure {
      rethrow;
    } on Object {
      throw const DiaryFailure('network');
    } finally {
      client.close(force: true);
    }
  }

  Map<String, dynamic> _json(Uint8List bytes) =>
      jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  @override
  Future<bool> available() async =>
      configured &&
      _json(await _request('GET', '/health', anonymous: true))['enabled'] ==
          true;
  @override
  Future<void> consent() async {
    if (await _storage.read(key: _key) != null) return;
    final data = _json(
      await _request(
        'POST',
        '/sessions',
        anonymous: true,
        json: {
          'offsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          'consentVersion': 'photo-transfer-v1',
        },
      ),
    );
    await _storage.write(key: _key, value: data['token'] as String);
  }

  @override
  Future<String> submit(String id, Uint8List photo) async =>
      _json(await _request('PUT', '/jobs/$id', bytes: photo))['state']
          as String;
  @override
  Future<String> status(String id) async =>
      _json(await _request('GET', '/jobs/$id'))['state'] as String;
  @override
  Future<Uint8List> image(String id) => _request('GET', '/jobs/$id/image');
  @override
  Future<void> acknowledge(String id) async {
    await _request('POST', '/jobs/$id/ack');
  }

  @override
  Future<void> delete(String id) async {
    await _request('DELETE', '/jobs/$id');
  }

  @override
  Future<void> deleteSession() async {
    if (await _storage.read(key: _key) == null) return;
    try {
      await _request('DELETE', '/session');
    } on DiaryFailure catch (e) {
      if (e.code != 'unauthorized') rethrow;
    }
    await _storage.delete(key: _key);
  }
}
