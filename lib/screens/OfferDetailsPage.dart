import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../services/ApiService.dart';
import '../models/DriveModel.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';

class OfferDetailsPage extends StatefulWidget {
  final int driveId;
  final String driveDetails;
  final double basePrice;
  final int driverId;

  const OfferDetailsPage({
    Key? key,
    required this.driveId,
    required this.driveDetails,
    required this.basePrice,
    required this.driverId,
  }) : super(key: key);

  @override
  _OfferDetailsPageState createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  final ApiService _apiService = ApiService();
  late Future<Drive> _driveFuture;
  late Future<List<Reservation>> _reservationsFuture;
  late Map<int, User> _userCache; // Cache for User data

  @override
  void initState() {
    super.initState();
    _userCache = {};
    _initializeData();
  }

  void _initializeData() {
    _driveFuture = _apiService.getDriveDetails(widget.driveId);
    _reservationsFuture = _fetchReservationsWithUserDetails();
  }

  Future<List<Reservation>> _fetchReservationsWithUserDetails() async {
    final reservations =
        await _apiService.getReservationsByDriveId(widget.driveId);

    for (final reservation in reservations) {
      if (reservation.user == null && reservation.userId != null) {
        // Fetch user details if not already cached
        if (!_userCache.containsKey(reservation.userId)) {
          final userResponse =
              await _apiService.fetchUserById(reservation.userId!);
          final user = User.fromJson(userResponse); // Convert to User object
          _userCache[reservation.userId!] = user;
        }
        // Assign the user to the reservation
        reservation.user = _userCache[reservation.userId];
      }
    }

    return reservations;
  }

  Future<void> _updateReservationStatus(
      int reservationId, String status) async {
    try {
      await _apiService.updateReservationStatus(reservationId, status);
      setState(() {
        _reservationsFuture = _fetchReservationsWithUserDetails();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation $status successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reservation: $e')),
      );
    }
  }

  void _navigateToChat(User? reservationUser) {
    if (reservationUser != null) {
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'senderId': widget.driverId, // Driver ID
          'receiverId': reservationUser.id, // User ID
          'receiverName': '${reservationUser.firstName} ',
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User details are missing.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<Drive>(
        future: _driveFuture,
        builder: (context, driveSnapshot) {
          if (driveSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (driveSnapshot.hasError) {
            return Center(
                child: Text('Error fetching drive: ${driveSnapshot.error}'));
          }

          final drive = driveSnapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title for Offer Details
                  const Text(
                    'Offer Details', // Title text
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${drive.pickup} → ${drive.destination}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Description: ${drive.description}',
                      style: const TextStyle(fontSize: 16)),
                  Text('Price: ${drive.price.toStringAsFixed(2)} MAD',
                      style:
                          const TextStyle(fontSize: 16, color: Colors.green)),
                  Text('Seats Available: ${drive.seating}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Departure: ${drive.deptime.toLocal()}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Reservations',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Reservation>>(
                    future: _reservationsFuture,
                    builder: (context, reservationsSnapshot) {
                      if (reservationsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (reservationsSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error fetching reservations: ${reservationsSnapshot.error}'));
                      }

                      final reservations = reservationsSnapshot.data ?? [];
                      if (reservations.isEmpty) {
                        return const Center(
                            child: Text('No reservations for this drive.'));
                      }

                      // Reverse the order of the list for displaying oldest to newest
                      final reversedReservations =
                          List.from(reservations.reversed);

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reversedReservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reversedReservations[index];
                          final user = reservation.user;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                '${user?.firstName ?? 'Unknown'} ${user?.lastName}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Seats: ${reservation.seats}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey)),
                                  Text('Status: ${reservation.status}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: _getStatusColor(
                                              reservation.status))),
                                ],
                              ),
                              trailing: reservation.status == 'PENDING'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () =>
                                              _updateReservationStatus(
                                                  reservation.id, 'ACCEPTED'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _updateReservationStatus(
                                                  reservation.id, 'REFUSED'),
                                        ),
                                      ],
                                    )
                                  : reservation.status == 'ACCEPTED'
                                      ? IconButton(
                                          icon: const Icon(Icons.chat,
                                              color: Colors.blue),
                                          onPressed: () =>
                                              _navigateToChat(reservation.user),
                                        )
                                      : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'REFUSED':
        return Colors.red;
      case 'CANCELED':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      case 'PAY':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
