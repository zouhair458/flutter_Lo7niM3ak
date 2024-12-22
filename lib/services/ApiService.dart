import 'package:flutter_application_1/models/DriveModel.dart';
import 'package:flutter_application_1/models/Message.dart';
import 'package:flutter_application_1/models/reservation_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.10.2.119:8080/api/v1';
  final Map<String, String> headers = {'Content-Type': 'application/json'};

  // Fetch all drives
  Future<List<dynamic>> fetchAllDrives() async {
    final response = await http.get(Uri.parse('$baseUrl/drives'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load drives');
    }
  }

  // Fetch driver details by ID
  Future<Map<String, dynamic>> fetchDriverById(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$driverId'));

    if (response.statusCode == 200) {
      // Assurez-vous que le JSON contient les informations attendues
      final data = jsonDecode(response.body);
      return data; // Retourne les données du conducteur
    } else {
      throw Exception('Failed to load driver details');
    }
  }

  // Fetch user profile by ID
  Future<Map<String, dynamic>> fetchUserById(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user profile: ${response.body}");
    }
  }

  // Update user role
  Future<void> updateUserRole(String email, String newRole) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/user/role'),
      body: {'email': email, 'newRole': newRole},
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update role: ${response.body}");
    }
  }

  // Fetch reviews for a user
  Future<List<dynamic>> fetchUserReviews(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/user/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Ensure this returns List<dynamic>
    } else {
      throw Exception("Failed to load user reviews: ${response.body}");
    }
  }

  // Add a new car
  Future<void> addCar(Map<String, dynamic> carData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cars'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'manufacturer': carData['manufacturer'],
        'model': carData['model'],
        'number_of_seats': carData['number_of_seats'],
        'color': carData['color'],
        'licence_plate': carData['licence_plate'],
        'userId': carData['userId'], // Add userId to the request body
        'user': {'id': carData['userId']},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add car: ${response.body}');
    }
  }

  Future<Drive> getDriveDetails(int driveId) async {
    final String url =
        '$baseUrl/drives/findDriveById/$driveId'; // Corrected path
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Drive.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Drive not found with ID: $driveId');
      } else {
        throw Exception(
            'Failed to fetch drive details. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching drive details: $error');
    }
  }

  // Fetch cars for a user
  Future<List<dynamic>> fetchUserCars(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/findCarByUserId/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load user cars: ${response.body}");
    }
  }

  // Register user
  Future<void> registerUser(
    String email,
    String password,
    String name,
    String firstName,
    String phone,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'firstName': firstName,
        'phone': phone,
        'role': role,
      }),
    );
  }

  // Login user
  Future<User> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/user/login?email=$email&password=$password'), // Envoyer comme paramètres URL
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to login: ${response.body}");
    }
  }

  Future<void> createReview(int userId, int note, String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': {
          'id': userId
        }, // Correctly map the user as an object with an ID
        'note': note,
        'message': message,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create review: ${response.body}");
    }
  }

// Fetch average note for a driver
  Future<double> getAverageNoteByDriverId(int driverId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/reviews/user/$driverId/average-note'));
    if (response.statusCode == 200) {
      return double.tryParse(response.body) ?? 0.0;
    } else {
      throw Exception('Failed to fetch average note');
    }
  }

  Future<User> getDriverById(int driverId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$driverId'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch driver details');
    }
  }

// Fetch reservations by drive ID
  Future<List<Reservation>> getReservationsByDriveId(int driveId) async {
    final String url =
        '$baseUrl/drives/drive/$driveId/reservations'; // Corrected path
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Reservation.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch reservations for drive ID $driveId');
      }
    } catch (error) {
      throw Exception('Error fetching reservations: $error');
    }
  }

// Create a new drive.
  Future<void> createDrive(
    int driverId,
    String pickup,
    String destination,
    DateTime deptime,
    double price,
    int seating,
    String description,
  ) async {
    const String url = '$baseUrl/drives';

    try {
      print("Creating drive for Driver ID: $driverId");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'driverId': driverId,
          'pickup': pickup,
          'destination': destination,
          'deptime': deptime.toIso8601String(),
          'price': price,
          'seating': seating,
          'description': description,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Drive created successfully: ${response.body}");
      } else {
        print("Error Response: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to create drive');
      }
    } catch (error) {
      print("Exception occurred while creating drive: $error");
      throw Exception('An error occurred while creating the drive');
    }
  }

// Fonction pour récupérer tous les drives créés par un driver
  Future<List<Drive>> getDrivesByDriver(int driverId) async {
    final String url = '$baseUrl/drives/findListDriveByUserId/$driverId';

    try {
      print("Request URL: $url");
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is List) {
          return jsonData.map((data) => Drive.fromJson(data)).toList();
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
            "Failed to fetch drives. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error while fetching drives: $error");
      throw Exception("Error fetching drives: $error");
    }
  }

// Update reservation status
  Future<void> updateReservationStatus(int reservationId, String status) async {
    String url;

    // Map the status to the correct endpoint
    switch (status) {
      case 'ACCEPTED':
        url = '$baseUrl/reservations/$reservationId/accept';
        break;
      case 'REFUSED':
        url = '$baseUrl/reservations/$reservationId/refuse';
        break;
      case 'CANCELED':
        url = '$baseUrl/reservations/$reservationId/cancel';
        break;
      default:
        throw Exception('Invalid status');
    }

    try {
      print("Updating reservation ID $reservationId to status $status");

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print("Reservation status updated successfully");
      } else {
        print("Error Response: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update reservation status');
      }
    } catch (error) {
      print("Error while updating reservation status: $error");
      throw Exception('Error while updating reservation status: $error');
    }
  }

  Future<void> createReservation(int userId, int driveId, int seats) async {
    final url =
        Uri.parse('$baseUrl/reservations'); // URL for creating reservation

    final reservationData = {
      'userId': userId,
      'driveId': driveId,
      'seats': seats,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reservationData),
      );

      // Handle responses properly
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Reservation created successfully.");
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: ${response.body}');
      } else if (response.statusCode == 404) {
        throw Exception('Drive or user not found: ${response.body}');
      } else {
        throw Exception('Failed to create reservation: ${response.body}');
      }
    } catch (e) {
      // Catch and rethrow exceptions with detailed error messages
      throw Exception('Error creating reservation: $e');
    }
  }

  Future<void> logout(String email) async {
    final url = Uri.parse('$baseUrl/user/logout');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to logout: ${response.body}');
      }
      print("Logout successful.");
    } catch (e) {
      throw Exception('Error logging out: $e');
    }
  }

  // Reservation APIs
  Future<List<Reservation>> getReservationsByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/reservations/user/$userId');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((data) => Reservation.fromJson(data))
          .toList();
    } else {
      throw Exception("Failed to fetch reservations: ${response.body}");
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final url = Uri.parse('$baseUrl/reservations/$reservationId/cancel');
    final response = await http.put(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel reservation: ${response.body}");
    }
  }

  // Chat APIs
  Future<List<User>> getConversationsByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/my-conversations/$userId');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((data) => User.fromJson(data))
          .toList();
    } else {
      throw Exception("Failed to fetch conversations: ${response.body}");
    }
  }

  Future<List<Message>> getConversation(int senderId, int receiverId) async {
    final String url =
        '$baseUrl/conversation?userId1=$senderId&userId2=$receiverId';
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((data) => Message.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to fetch conversation: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error fetching conversation: $error');
    }
  }
}
