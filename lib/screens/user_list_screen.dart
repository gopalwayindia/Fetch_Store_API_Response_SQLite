import 'dart:convert';

import 'package:apiresponse_in_sqlite/helpers/database_helper.dart';
import 'package:apiresponse_in_sqlite/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _fetchAndStoreData() async {
    var url = Uri.parse('https://jsonplaceholder.typicode.com/users');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> users = json.decode(response.body);

      DatabaseHelper dbHelper = DatabaseHelper();
      for (var user in users) {
        await dbHelper.insertUser({
          'id': user['id'],
          'name': user['name'],
          'username': user['username'],
          'email': user['email'],
          'address': json.encode(user['address']),
          'phone': user['phone'],
          'website': user['website'],
          'company': json.encode(user['company']),
        });
      }
      _loadUsers(); // Reload users after fetching and storing
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _loadUsers() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> userList = await dbHelper.getUsers();
    setState(() {
      _users = userList.map((user) => _convertToUser(user)).toList();
    });
  }

  User _convertToUser(Map<String, dynamic> userMap) {
    return User(
      id: userMap['id'],
      name: userMap['name'],
      username: userMap['username'],
      email: userMap['email'],
      address: userMap['address'],
      phone: userMap['phone'],
      website: userMap['website'],
      company: userMap['company'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _fetchAndStoreData,
            child: Text('Sync Data'),
          ),
          Expanded(
            child: _users != null
                ? ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          title: Text(_users[index].name),
                          subtitle: Text(_users[index].email),
                          // Add other user details as needed
                        ),
                      );
                    },
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
