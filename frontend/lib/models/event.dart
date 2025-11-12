class Event {
  final int id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final bool isActive;

  Event({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    this.location,
    required this.isActive,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      location: json['location'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'is_active': isActive,
    };
  }
}
