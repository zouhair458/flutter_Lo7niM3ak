import 'dart:convert';
import 'package:flutter_application_1/models/DriveModel.dart';
import 'package:flutter_application_1/models/reservationDto.dart';
import 'package:flutter_application_1/models/reservation_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'package:http/http.dart' as http;

class ReservationService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  ReservationService(ApiService apiService);

  Future<List<Reservation>> fetchReservationsByUserId(int userId) async {
  final url = Uri.parse('$baseUrl/reservations/user/$userId');

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> reservationsData = jsonDecode(response.body);

      // Fetch Drive and User details for each reservation
      List<Reservation> reservations = await Future.wait(
        reservationsData.map<Future<Reservation>>((data) async {
          final reservationDto = ReservationDto.fromJson(data);

          // Fetch associated Drive and User
          try {
            final drive = await fetchDriveById(reservationDto.driveId);
            final user = await fetchUserById(reservationDto.userId);

            return Reservation(
              id: reservationDto.id,
              seats: reservationDto.seats,
              status: reservationDto.status,
              drive: drive,
              user: user,
            );
          } catch (error) {
            print(
                'Error fetching associated Drive or User for reservation ID ${reservationDto.id}: $error');
            throw Exception(
                'Failed to fetch Drive or User details for reservation ID ${reservationDto.id}');
          }
        }).toList(),
      );

      return reservations;
    } else {
      // Handle non-200 responses
      throw Exception(
          'Failed to load reservations for user ID $userId: ${response.body}');
    }
  } catch (e) {
    print('Error fetching reservations for user ID $userId: $e');
    throw Exception('Failed to fetch reservations for user ID $userId');
  }
}


  // Create payment intent for reservation
  Future<String?> createPaymentIntent(int reservationId) async {
    try {
      final url = Uri.parse('$baseUrl/reservations/$reservationId/payment-intent');
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['client_secret'];
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }


  // Get reservations for a user
  Future<List<Reservation>> getReservations(int userId) async {
    return await fetchReservationsByUserId(userId);
  }

  // Cancel a reservation
  Future<void> cancelReservation(int reservationId) async {
    final url = Uri.parse('$baseUrl/reservations/$reservationId/cancel');

    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel reservation: ${response.body}');
      }
    } catch (e) {
      print('Error canceling reservation: $e');
      throw Exception('Failed to cancel reservation');
    }
  }

  Future<List<Reservation>> getReservationsByDriveId(int driveId) async {
    final String url = '$baseUrl/reservations/drive/$driveId';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.isEmpty) {
          return [];
        }

        return jsonData.map((data) {
          if (data is Map<String, dynamic>) {
            return Reservation.fromJson(data);
          } else {
            throw Exception("Invalid data format: $data");
          }
        }).toList();
      } else {
        throw Exception('Failed to fetch reservations for drive ID $driveId');
      }
    } catch (error) {
      throw Exception('Error while fetching reservations: $error');
    }
  }

  

// Fetch User by ID
Future<User> fetchUserById(int userId) async {
  final url = Uri.parse('${ApiService.baseUrl}/user/$userId');
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch User with ID $userId: ${response.body}");
  }
}


  // Private method to fetch user by ID
  // Fetch Drive by ID
Future<Drive> fetchDriveById(int driveId) async {
  final url = Uri.parse('${ApiService.baseUrl}/drives/findDriveById/$driveId');
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    return Drive.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch Drive with ID $driveId: ${response.body}");
  }
}


}
