// lib/models/user.dart
class User {
  final String id;   // MongoDB ObjectId
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> roles;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.roles = const [],
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    avatarUrl: json['avatar_url'],
    roles: json['roles'] != null
        ? List<String>.from(
        (json['roles'] as List).map((r) => r is Map ? (r['name'] ?? '') : r.toString()))
        : [],
    token: json['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email,
    'avatar_url': avatarUrl, 'roles': roles,
  };

  bool get isSuperAdmin => roles.contains('super_admin');
  bool get isAdmin => roles.contains('super_admin') || roles.contains('admin');

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

// lib/models/survey.dart
class Survey {
  final String id;   // MongoDB ObjectId
  final String namaSurvey;
  final DateTime? createdAt;
  int jumlahKuesioner;

  Survey({
    required this.id,
    required this.namaSurvey,
    this.createdAt,
    this.jumlahKuesioner = 0,
  });

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    namaSurvey: json['nama_survey'] ?? '',
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    jumlahKuesioner: json['questionnaires_count'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama_survey': namaSurvey,
  };
}