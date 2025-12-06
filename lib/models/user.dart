import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final String role;

  @HiveField(4)
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum UserRole {
  admin,
  employee,
}
