import 'package:flutter/material.dart';
import '../../../core/theme_notifier.dart';
import '../../../data/services/github_api_service.dart';
import '../../../data/models/user_model.dart';
import '../widgets/user_list_item.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  List<User> users = [];
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
              itemBuilder: (context, index) => UserListItem(user: users[index]),
            ),
          ),
        ],
      ),
    );
  }
}
