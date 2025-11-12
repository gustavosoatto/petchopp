import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import '../models/user.dart';

class CheckInScreen extends StatefulWidget {
  final User user;

  CheckInScreen({required this.user});

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  late Future<User> _checkInFuture;

  @override
  void initState() {
    super.initState();
    _checkInFuture = ApiService().checkIn(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-In'),
      ),
      body: FutureBuilder<User>(
        future: _checkInFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${snapshot.data!.name}!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: ${snapshot.data!.email}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Checked in at: ${snapshot.data!.entryTime}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
