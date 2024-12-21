import 'package:flutter_application_1/models/user_model.dart';

class Drive {
  final int id;
  final String pickup;
  final String destination;
  final DateTime deptime;
  final double price;
  final int seating;
  final String description;
  late User user;

  Drive({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.deptime,
    required this.price,
    required this.seating,
    required this.description,
    required this.user,
  });

  factory Drive.fromJson(Map<String, dynamic> json) {
    return Drive(
      id: json['id'] ?? 0,
      pickup: json['pickup'] ?? '',
      destination: json['destination'] ?? '',
      deptime: DateTime.parse(json['deptime'] ?? DateTime.now().toString()),
      price: json['price']?.toDouble() ?? 0.0,
      seating: json['seating'] ?? 0,
      description: json['description'] ?? '',
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User(
              id: 0,
              firstName: 'Unknown',
              name: '',
              email: '',
              phone: '',
              role: 'Unknown',
              reviews: []),
    );
  }

  set status(String status) {}
}
