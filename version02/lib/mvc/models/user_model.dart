enum UserRole { user, admin, municipality }

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String mobile;
  final String? avatarUrl;
  final UserRole role;
  final bool isblocked;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    this.avatarUrl,
    this.role = UserRole.user,
    this.isblocked = false,
  });

  // ===convert the string into enum ===
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    // === get the string from the database ===
    String roleString = data['role'] ?? 'user';

    UserRole parsedRole = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.user, // in error, consider the user is user
    );

    return UserModel(
      id: id,
      email: data['email'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      mobile: data['mobile_num'] ?? '',
      avatarUrl: data['avatar_url'],
      role: parsedRole,
      isblocked: data['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile_num': mobile,
      'avatar_url': avatarUrl,
      'role': role.name, // transfer enum to string
      'isBlocked': isblocked,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? mobile,
    String? avatarUrl,
    UserRole? role,
    bool? isblocked,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isblocked: isblocked ?? this.isblocked,
    );
  }
}
