class UserModel {
  final String username;
  final String password;
  final String role;
  final String? fullName;
  final String? email;

  UserModel({
    required this.username,
    required this.password,
    required this.role,
    this.fullName,
    this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'fullName': fullName,
      'email': email,
    };
  }
}