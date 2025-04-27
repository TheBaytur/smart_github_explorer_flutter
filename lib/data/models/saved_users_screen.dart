import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/user_model.dart';
import '/presentation/screens/user_search_screen.dart';

class SavedUsersScreen extends StatelessWidget {
  final List<User> savedUsers;

  SavedUsersScreen({required this.savedUsers});

  void launchProfile(String username) async {
    final url = 'https://github.com/$username';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Users'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => UserSearchScreen(savedUsers: savedUsers)), // ✅ fixed
                    (Route<dynamic> route) => false,
              );
            },
          )
        ],
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
            onTap: () => launchProfile(user.username),
          );
        },
      ),
    );
  }
}
