import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../screens/user_repo_screen.dart';

class UserListItem extends StatelessWidget {
  final User user;

  UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
      title: Text(user.username),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserRepoScreen(username: user.username)),
        );
      },
    );
  }
}
