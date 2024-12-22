class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  late final String role;
  final List<dynamic>? reviews; // Peut être spécifié davantage si nécessaire
  final List<dynamic>? cars; // Peut être spécifié davantage si nécessaire
  final List<dynamic>? drives; // Peut être spécifié davantage si nécessaire
  final List<dynamic>? reservations; // Peut être spécifié davantage si nécessaire

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.reviews,
    this.cars,
    this.drives,
    this.reservations,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      reviews: json['reviews'] ?? [],
      cars: json['cars'] ?? [],
      drives: json['drives'] ?? [],
      reservations: json['reservations'] ?? [],
    );
  }

  get name => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role,
      'reviews': reviews,
      'cars': cars,
      'drives': drives,
      'reservations': reservations,
    };
  }
}
