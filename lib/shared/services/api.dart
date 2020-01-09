import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'cache.dart';

class ApiError {
  final int errorCode;

  ApiError(this.errorCode);

  ApiError.fromJSON(Map<String, dynamic> raw) : errorCode = raw['error_code'];
}

class ApiService {
  factory ApiService() => _instance;
  static final ApiService _instance = ApiService._internal();

  ApiService._internal();

  static const _host = 'http://nastik-trip.com';

  final Cache _cache = Cache();

  Future<dynamic> get(
    String url, {
    String contentType,
    String token,
    String responseType,
    bool cache = false,
    bool forceCache = false,
  }) async {
    final String cacheKey = url;

    if (cache && !forceCache) {
      final String cached = await _cache.get(cacheKey);
      if (cached != null) {
        return json.decode(cached);
      }
    }

    final Function request = () {
      return http.get(
        _host + url,
        headers: _withToken(
          token,
          {
            'Content-Type': contentType != null
                ? contentType
                : 'application/json; charset=utf-8',
            'responseType': 'blob',
          },
        ),
      );
    };

    return request().then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        print(response.body);
        throw Exception(response);
      }
      if (contentType == null) {
        _setCache(cacheKey, response.body);
        return json.decode(response.body);
      }
      return response.bodyBytes;
    });
  }

  Future<dynamic> post(
    String url, {
    Map body,
    String token,
    String contentType,
    bool raw = false,
    bool cache = false,
    bool forceCache = false,
  }) async {
    final String cacheKey = url + (body != null ? json.encode(body) : '');

    if (cache && !forceCache) {
      final String cached = await _cache.get(cacheKey);
      if (cached != null) {
        final Map decoded = json.decode(cached);
        return raw ? decoded : decoded['result'];
      }
    }

    final Function request = () {
      return http.post(
        _host + url,
        headers: _withToken(token, {
          'Content-Type': contentType != null
              ? contentType
              : 'application/json; charset=utf-8',
        }),
        body: json.encode(body),
      );
    };

    return request().then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400) {
        throw ApiError.fromJSON(json.decode(response.body));
      }
      _setCache(cacheKey, response.body);
      final Map decoded = json.decode(response.body);
      return raw ? decoded : decoded['result'];
    });
  }

  Future<dynamic> sendFile({
    @required String url,
    @required String filename,
    @required Function getData,
    Function(FormData, UploadFileInfo) prepare,
    String token,
  }) async {
    final file = filename != null
        ? UploadFileInfo.fromBytes(
            await File(filename).readAsBytes(),
            basename(filename),
          )
        : [];

    FormData body = FormData.from(getData(file));
    if (prepare != null) {
      body = prepare(body, file);
    }

    final Dio dio = Dio();

    return dio
        .post(
      _host + url,
      data: body,
      options: Options(
        headers: _withToken(token, {
          'Content-Type': 'multipart/form-data',
        }),
      ),
    )
        .then((Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        throw Exception(response.data);
      }
      return response.data['result'];
    }).catchError((e) {
      print(e.response);
    });
  }


  Map<String, String> _withToken(
    String passedToken,
    Map<String, String> headers,
  ) {
    String token = 'token';
    headers['X-Token'] = token;
    headers['X-Authentication-Token'] = token;
    headers['X-AUTHENTICATION-TOKEN'] = token;

    return headers;
  }

  _setCache(String cacheKey, String value) {
    _cache.set(cacheKey, value);
  }
}
