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
