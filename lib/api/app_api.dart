import 'dart:convert';
import 'package:halalsefllearning/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppApi {
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'authorization': 'Bearer ${prefs.getString("access_token") ?? ""}'
    };
  }

  static Future<http.Response> get(String url) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
    final headers = await _getHeaders();
    print("GET: $fullUrl");
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }

  static Future<http.Response> getWithParams(String url, String params) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl/$params";
    final headers = await _getHeaders();
    print("GET: $fullUrl");
    return await http.get(Uri.parse(fullUrl), headers: headers);
  }

  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
    final headers = await _getHeaders();
    print("POST: $fullUrl");
    return await http.post(
      Uri.parse(fullUrl),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
    final headers = await _getHeaders();
    print("PUT: $fullUrl");
    return await http.put(
      Uri.parse(fullUrl),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> patch(String url, Map<String, dynamic> body) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
    final headers = await _getHeaders();
    print("PATCH: $fullUrl");
    return await http.patch(
      Uri.parse(fullUrl),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String url) async {
    String cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    String fullUrl = "${AppConfig.apiBaseUri}/$cleanUrl";
    final headers = await _getHeaders();
    print("DELETE: $fullUrl");
    return await http.delete(Uri.parse(fullUrl), headers: headers);
  }

  // แปลง response ที่อยู่ในรูป { isError, data, errorMessage } แล้วคืนค่า data
  // ถ้า HTTP status ไม่ใช่ 2xx หรือ isError เป็น true จะ throw AppApiException
  static dynamic unwrap(http.Response response) {
    dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (_) {
      throw AppApiException('HTTP ${response.statusCode}: ${response.body}');
    }
    final bool ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || (json is Map && json['isError'] == true)) {
      final message = json is Map
          ? (json['errorMessage'] ?? json['error'] ?? 'HTTP ${response.statusCode}')
          : 'HTTP ${response.statusCode}';
      throw AppApiException(message.toString());
    }
    return json is Map ? json['data'] : json;
  }
}

class AppApiException implements Exception {
  final String message;
  AppApiException(this.message);

  @override
  String toString() => message;
}