import 'package:flutter/material.dart';
import 'package:frontend/screens/nfc_reading_screen.dart';
import 'package:frontend/screens/qr_view_screen.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User>> _users;
  List<User> _filteredUsers = [];
  TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _users = ApiService().getUsers();
    _users.then((users) {
      setState(() {
        _filteredUsers = users;
      });
    });
  }

  void _filterUsers(String query) {
    _users.then((users) {
      setState(() {
        if (query.isEmpty) {
          _filteredUsers = users;
          _isSearching = false;
        } else {
          _filteredUsers = users
              .where((user) =>
                  user.name.toLowerCase().contains(query.toLowerCase()) ||
                  user.email.toLowerCase().contains(query.toLowerCase()))
              .toList();
          _isSearching = true;
        }
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _users.then((users) {
      setState(() {
        _filteredUsers = users;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered Users'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: _clearSearch,
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRViewScreen()),
                  );
                  if (result != null) {
                    _users.then((users) {
                      final foundUser = users.firstWhere((user) => user.id.toString() == result, orElse: () => User(id: 0, name: '', email: ''));
                      if (foundUser.id != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckInScreen(user: foundUser),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User not found'),
                          ),
                        );
                      }
                    });
                  }
                },
                child: Text('QR Code'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NfcReadingScreen()),
                  );
                  if (result != null) {
                    _users.then((users) {
                      final foundUser = users.where((user) => user.id.toString() == result);
                      if (foundUser.isNotEmpty) {
                        setState(() {
                          _filteredUsers = foundUser.toList();
                          _isSearching = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User not found'),
                          ),
                        );
                      }
                    });
                  }
                },
                child: Text('NFC'),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _users,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredUsers[index].name),
                        subtitle: Text(_filteredUsers[index].email),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
