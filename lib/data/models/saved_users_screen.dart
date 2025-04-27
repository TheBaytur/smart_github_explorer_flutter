import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';

class SavedUsersScreen extends StatelessWidget {
  final List<User> savedUsers;

  SavedUsersScreen({required this.savedUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Users'),
      ),
      body: savedUsers.isEmpty
          ? Center(child: Text('No users saved yet ⭐'))
          : ListView.builder(
        itemCount: savedUsers.length,
        itemBuilder: (context, index) {
          final user = savedUsers[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
            title: Text(user.username),
          );
        },
      ),
    );
  }
}
