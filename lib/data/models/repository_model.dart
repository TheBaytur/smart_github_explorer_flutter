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
