class User {
  final int id;
  final String name;
  final String firstName;
  final String email;
  final String phone;
  String role; // Mutable role
  final List<String> reviews;

  User({
    required this.id,
    required this.firstName,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.reviews,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      name: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      reviews: (json['reviews'] is List)
          ? List<String>.from(json['reviews'].map((e) => e.toString()))
          : [],
    );
  }
}
