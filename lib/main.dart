import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(MyApp());
}

// ✅ MyApp widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: "Smart GitHub Explorer",
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
          ),
          themeMode: currentMode,
          home: UserSearchScreen(),
        );
      },
    );
  }
}


// ✅ User model
class User {
  final String username;
  final String avatarUrl;

  User({required this.username, required this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['login'],
      avatarUrl: json['avatar_url'],
    );
  }
}

// ✅ Repository model
class Repository {
  final String name;
  final String? description;
  final String? language;
  final int stars;
  final String url;
  final bool isFork;

  Repository({
    required this.name,
    this.description,
    this.language,
    required this.stars,
    required this.url,
    required this.isFork,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'],
      description: json['description'],
      language: json['language'],
      stars: json['stargazers_count'],
      url: json['html_url'],
      isFork: json['fork'],
    );
  }
}

// ✅ UserSearchScreen
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

    final token = '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'; // Replace here
    final response = await http.get(
      Uri.parse('https://api.github.com/search/users?q=$query'),
      headers: { 'Authorization': 'token $token' },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users = List<User>.from(data['items'].map((u) => User.fromJson(u)));
        isLoading = false;
      });
    } else {
      setState(() {
        users = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    searchUsers("flutter"); // Example default search
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
              themeNotifier.value =
              themeNotifier.value == ThemeMode.light
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
              onChanged: (query) => searchUsers(query),
            ),
          ),
          Expanded(
            child: isLoading
                ? ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: ListTile(
                  leading: CircleAvatar(radius: 20, backgroundColor: Colors.white),
                  title: Container(height: 10, color: Colors.white),
                  subtitle: Container(height: 10, margin: EdgeInsets.only(top: 5), color: Colors.white),
                ),
              ),
            )
                : users.isEmpty
                ? Center(child: Text('No users found 😢'))
                : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: 1.0,
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                    title: Text(user.username),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => UserRepoScreen(username: user.username),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ UserRepoScreen
class UserRepoScreen extends StatefulWidget {
  final String username;

  UserRepoScreen({required this.username});

  @override
  _UserRepoScreenState createState() => _UserRepoScreenState();
}

class _UserRepoScreenState extends State<UserRepoScreen> {
  List<Repository> repos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRepos();
  }

  Future<void> fetchRepos() async {
    final token = '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'; // Replace here
    final response = await http.get(
      Uri.parse('https://api.github.com/users/${widget.username}/repos'),
      headers: { 'Authorization': 'token $token' },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        repos = data
            .map((r) => Repository.fromJson(r))
            .where((r) => !r.isFork)
            .toList();
        isLoading = false;
      });
    }
  }

  void launchURL(String url) async {
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
      appBar: AppBar(title: Text("${widget.username}'s Repositories")),
      body: isLoading
          ? ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            title: Container(height: 10, color: Colors.white),
            subtitle: Container(height: 10, margin: EdgeInsets.only(top: 5), color: Colors.white),
          ),
        ),
      )
          : repos.isEmpty
          ? Center(child: Text('No repositories found 😢'))
          : ListView.builder(
        itemCount: repos.length,
        itemBuilder: (context, index) {
          final repo = repos[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeIn,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(repo.name),
              subtitle: Text(repo.description ?? 'No description'),
              trailing: Text('⭐ ${repo.stars}'),
              onTap: () => launchURL(repo.url),
            ),
          );
        },
      ),
    );
  }
}
