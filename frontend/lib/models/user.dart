class User {
  final int id;
  final String name;
  final String email;
  final String? entryTime;

  User({required this.id, required this.name, required this.email, this.entryTime});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      entryTime: json['entry_time'],
    );
  }
}
