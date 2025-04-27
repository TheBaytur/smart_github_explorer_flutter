import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/repository_model.dart';

class GithubApiService {
  static const _token = 'TOKEN';

  static Future<List<User>> searchUsers(String query) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/search/users?q=$query'),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'FlutterApp',
      },
    );

    print('==================');
    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
    print('==================');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<User>.from(data['items'].map((u) => User.fromJson(u)));
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<List<Repository>> fetchRepositories(String username) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/$username/repos'),
      headers: {
        'Authorization': 'token $_token',
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'FlutterApp',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((r) => Repository.fromJson(r))
          .where((r) => !r.isFork)
          .toList();
    } else {
      throw Exception('Failed to load repositories');
    }
  }
}
