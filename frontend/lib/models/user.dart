class User {
  final int id;
  final String name;
  final String email;
  final String? entryTime;
  final String? entryCode;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.entryTime,
    this.entryCode,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      entryTime: json['entry_time'],
      entryCode: json['entry_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'entry_time': entryTime,
      'entry_code': entryCode,
    };
  }
}
