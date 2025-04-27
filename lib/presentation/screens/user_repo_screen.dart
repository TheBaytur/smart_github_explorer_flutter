import 'package:flutter/material.dart';
import '../../../data/services/github_api_service.dart';
import '../../../data/models/repository_model.dart';
import '../widgets/repo_list_item.dart';

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
    try {
      repos = await GithubApiService.fetchRepositories(widget.username);
    } catch (_) {
      repos = [];
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}'s Repositories")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : repos.isEmpty
          ? Center(child: Text('No repositories found 😢'))
          : ListView.builder(
        itemCount: repos.length,
        itemBuilder: (context, index) => RepoListItem(repo: repos[index]),
      ),
    );
  }
}
