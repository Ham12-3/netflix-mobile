class AppUser {
  const AppUser({required this.id, required this.email, this.displayName});

  final String id;
  final String email;
  final String? displayName;

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return email.split('@').first;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
    );
  }
}
