import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = "http://10.140.17.100:8000/api";

  static Future<Map<String,dynamic>> register(Map<String,String> data) async {
    final response = await http.post(Uri.parse('$baseUrl/register'), body: data);
    return json.decode(response.body);
  }

  static Future<Map<String,dynamic>> login(Map<String,String> data) async {
    final response = await http.post(Uri.parse('$baseUrl/login'), body: data);
    return json.decode(response.body);
  }
}

