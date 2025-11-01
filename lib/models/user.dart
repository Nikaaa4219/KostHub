// Auto-generated — manual review required
// File: lib/models/user.dart
// Simple User model used for profile update stubs and local state.

class User {
  final String name;
  final String email;
  final String? phone;
  final DateTime? dob;
  final String? gender;

  User({
    required this.name,
    required this.email,
    this.phone,
    this.dob,
    this.gender,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    DateTime? dob,
    String? gender,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob?.toIso8601String(),
      'gender': gender,
    };
  }

  factory User.fromMap(Map<String, dynamic> m) {
    return User(
      name: m['name'] as String? ?? '',
      email: m['email'] as String? ?? '',
      phone: m['phone'] as String?,
      dob: m['dob'] != null ? DateTime.parse(m['dob'] as String) : null,
      gender: m['gender'] as String?,
    );
  }
}
