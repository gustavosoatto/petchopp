import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/event.dart';
import '../models/event_entry.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost/api';

  // Users
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

  // Events
  Future<Event> getActiveEvent() async {
    final response = await http.get(Uri.parse('$_baseUrl/events-active'));

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('No active event found');
    }
  }

  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse('$_baseUrl/events'));

    if (response.statusCode == 200) {
      final List<dynamic> eventList = jsonDecode(response.body);
      return eventList.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  // Event Entries
  Future<EventEntry> checkInByCode(String code, String method) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/check-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'entry_method': method,
      }),
    );

    if (response.statusCode == 201) {
      return EventEntry.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 409) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'User already checked in');
    } else {
      throw Exception('Failed to check in');
    }
  }

  Future<List<EventEntry>> getEventEntries(int eventId) async {
    final response = await http.get(Uri.parse('$_baseUrl/events/$eventId/entries'));

    if (response.statusCode == 200) {
      final List<dynamic> entriesList = jsonDecode(response.body);
      return entriesList.map((json) => EventEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load entries');
    }
  }

  Future<List<EventEntry>> getAllEntries() async {
    final response = await http.get(Uri.parse('$_baseUrl/entries'));

    if (response.statusCode == 200) {
      final List<dynamic> entriesList = jsonDecode(response.body);
      return entriesList.map((json) => EventEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load entries');
    }
  }
}
