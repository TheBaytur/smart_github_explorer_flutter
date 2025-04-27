import 'package:flutter/material.dart';
import '../../../core/theme_notifier.dart';
import '../../../data/services/github_api_service.dart';
import '../../../data/models/user_model.dart';
import '../../data/models/saved_users_screen.dart'; // ✅ Correct import

import 'package:url_launcher/url_launcher.dart';

import '/presentation/screens/profile_webview_screen.dart';


class UserSearchScreen extends StatefulWidget {
  final List<User> savedUsers;

  UserSearchScreen({this.savedUsers = const []});

  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  late List<User> savedUsers;
  List<User> users = [];

  Future<void> launchProfile(String username) async {
    final url = 'https://github.com/$username';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    savedUsers = List<User>.from(widget.savedUsers);
    searchUsers("flutter");
  }

  bool isLoading = false;

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => isLoading = true);

    try {
      users = await GithubApiService.searchUsers(query);
    } catch (_) {
      users = [];
    }

    setState(() => isLoading = false);
  }

  void saveUser(User user) {
    if (!savedUsers.any((u) => u.username == user.username)) {
      setState(() {
        savedUsers.add(user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Users'),
        actions: [
          IconButton(
            icon: Icon(Icons.star_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavedUsersScreen(savedUsers: savedUsers)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              themeNotifier.value = themeNotifier.value == ThemeMode.light
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search users...',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[200]
                    : Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: searchUsers,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : users.isEmpty
                ? Center(child: Text('No users found 😢'))
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final alreadySaved = savedUsers.any((u) => u.username == user.username);

                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                  title: Text(user.username),
                  trailing: IconButton(
                    icon: Icon(
                      alreadySaved ? Icons.star : Icons.star_border,
                      color: alreadySaved ? Colors.amber : null,
                    ),
                    onPressed: () => saveUser(user),
                  ),
                  onTap: () async {
                    await launchProfile(user.username);
                    if (mounted) {
                      Navigator.pop(context); // 👈 go back after opening profile
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // ⬅️ go back
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SavedUsersScreen(savedUsers: savedUsers)),
                ); // ➡️ go to Saved Users
              },
            ),
          ],
        ),
      ),
    );
  }
}
