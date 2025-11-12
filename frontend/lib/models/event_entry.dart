import 'user.dart';
import 'event.dart';

class EventEntry {
  final int id;
  final int eventId;
  final int userId;
  final DateTime entryTime;
  final String entryMethod;
  final String? notes;
  final User? user;
  final Event? event;

  EventEntry({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.entryTime,
    required this.entryMethod,
    this.notes,
    this.user,
    this.event,
  });

  factory EventEntry.fromJson(Map<String, dynamic> json) {
    return EventEntry(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      entryTime: DateTime.parse(json['entry_time']),
      entryMethod: json['entry_method'],
      notes: json['notes'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'entry_time': entryTime.toIso8601String(),
      'entry_method': entryMethod,
      'notes': notes,
    };
  }
}
