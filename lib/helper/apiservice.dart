import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Future<http.Response> get(
    String path, [
    Map<String, String>? queryParams,
  ]) async {
    final uri = Uri.http('localhost:8000', '/api$path', queryParams);
    return http.get(uri, headers: await getHeaders());
  }

  static Future<http.Response> post(String path, [Map body = const {}]) async {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: await getHeaders(),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    return http.delete(Uri.parse('$baseUrl$path'), headers: await getHeaders());
  }

  static Future<http.Response> put(String path, Map body) async {
    return http.put(
      Uri.parse('$baseUrl$path'),
      headers: await getHeaders(),
      body: jsonEncode(body),
    );
  }
}
