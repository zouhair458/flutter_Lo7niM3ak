import 'DriveModel.dart';
import 'user_model.dart';

class Reservation {
  final int id;
  final int seats;
  final String status;
  final int? userId; // Add userId field
  User? user; // Make user mutable
  final Drive? drive; // Associated Drive (optional)
  final dynamic bill; // Placeholder for Bill (optional)

  Reservation({
    required this.id,
    required this.seats,
    required this.status,
    this.userId,
    this.user,
    this.drive,
    this.bill,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      seats: json['seats'] ?? 0,
      status: json['status'] ?? 'Unknown',
      userId: json['userId'] as int?, // Map userId from JSON
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      drive: json['drive'] != null ? Drive.fromJson(json['drive']) : null,
      bill: json['bill'], // Leave it as dynamic for now
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seats': seats,
      'status': status,
      'userId': userId, // Include userId in JSON
      'user': user?.toJson(),
      'drive': drive?.toJson(),
      'bill': bill,
    };
  }
}
