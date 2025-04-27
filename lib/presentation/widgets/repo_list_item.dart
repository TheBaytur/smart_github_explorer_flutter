import 'package:flutter/material.dart';
import '../../../data/models/repository_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoListItem extends StatelessWidget {
  final Repository repo;

  RepoListItem({required this.repo});

  void launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(repo.name),
      subtitle: Text(repo.description ?? 'No description'),
      trailing: Text('⭐ ${repo.stars}'),
      onTap: () => launchURL(repo.url),
    );
  }
}
