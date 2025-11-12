import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost/api';

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> userList = data['data'];
      return userList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> checkIn(int userId) async {
    final response = await http.post(Uri.parse('$_baseUrl/users/$userId/check-in'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to check in user');
    }
  }
}
