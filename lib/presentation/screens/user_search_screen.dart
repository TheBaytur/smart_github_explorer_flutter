import 'package:flutter/material.dart';
import '../../../core/theme_notifier.dart';
import '../../../data/services/github_api_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/saved_users_screen.dart'; // <-- new screen for saved users

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  List<User> users = [];
  List<User> savedUsers = []; // ⭐ Added this
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
  void initState() {
    super.initState();
    searchUsers("flutter");
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
                  onTap: () {
                    // Navigate to repo screen
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
