class Profile {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      avatarUrl: json['avatar_url'],
    );
  }
}
