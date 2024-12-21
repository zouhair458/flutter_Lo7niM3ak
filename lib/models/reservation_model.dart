import 'DriveModel.dart';
import 'user_model.dart';

class Reservation {
  final int id;
  final int seats;
  final String status;
  final Drive drive; // Associated Drive
  final User user; // Associated User

  Reservation({
    required this.id,
    required this.seats,
    required this.status,
    required this.drive,
    required this.user,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      seats: json['reservedSeats'] ?? 0,
      status: json['status'] ?? 'Unknown',
      drive: json['drive'] != null
          ? Drive.fromJson(json['drive'])
          : Drive(
              id: 0,
              pickup: 'Unknown',
              destination: 'Unknown',
              deptime: DateTime.now(),
              price: 0.0,
              seating: 0,
              description: 'No description',
              user: User(
                id: 0,
                name: 'Unknown',
                firstName: '',
                email: '',
                phone: '',
                role: 'Unknown',
                reviews: [],
              ),
            ),
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User(
              id: 0,
              name: 'Unknown',
              firstName: '',
              email: '',
              phone: '',
              role: 'Unknown',
              reviews: [],
            ),
    );
  }
}
