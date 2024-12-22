import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import '../services/ApiService.dart';

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
    final reservations = await _apiService.getReservationsByDriveId(widget.driveId);

    for (final reservation in reservations) {
      if (reservation.user == null && reservation.userId != null) {
        // Fetch user details if not already cached
        if (!_userCache.containsKey(reservation.userId)) {
          final userResponse = await _apiService.fetchUserById(reservation.userId!);
          final user = User.fromJson(userResponse); // Convert to User object
          _userCache[reservation.userId!] = user;
        }
        // Assign the user to the reservation
        reservation.user = _userCache[reservation.userId];
      }
    }

    return reservations;
  }

  Future<void> _updateReservationStatus(int reservationId, String status) async {
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
        'senderId': widget.driverId, // Conducteur connecté
        'receiverId': reservationUser.id, // Client ayant fait la réservation
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
        title: const Text('Offer Details'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Drive>(
        future: _driveFuture,
        builder: (context, driveSnapshot) {
          if (driveSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (driveSnapshot.hasError) {
            return Center(child: Text('Error fetching drive: ${driveSnapshot.error}'));
          }

          final drive = driveSnapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${drive.pickup} → ${drive.destination}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Description: ${drive.description}'),
                  Text('Price: ${drive.price.toStringAsFixed(2)} MAD'),
                  Text('Seats Available: ${drive.seating}'),
                  Text('Departure: ${drive.deptime.toLocal()}'),
                  const SizedBox(height: 16),
                  const Text('Reservations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<Reservation>>(
                    future: _reservationsFuture,
                    builder: (context, reservationsSnapshot) {
                      if (reservationsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (reservationsSnapshot.hasError) {
                        return Center(child: Text('Error fetching reservations: ${reservationsSnapshot.error}'));
                      }

                      final reservations = reservationsSnapshot.data ?? [];
                      if (reservations.isEmpty) {
                        return const Center(child: Text('No reservations for this drive.'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          final user = reservation.user;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                '${user?.firstName ?? 'Unknown'} ${user?.name ?? 'Unknown'}',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Seats: ${reservation.seats}'),
                                  Text('Status: ${reservation.status}'),
                                ],
                              ),
                              trailing: reservation.status == 'PENDING'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () => _updateReservationStatus(reservation.id, 'ACCEPTED'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () => _updateReservationStatus(reservation.id, 'REFUSED'),
                                        ),
                                      ],
                                    )
                                  : reservation.status == 'ACCEPTED'
                                      ? IconButton(
                                          icon: const Icon(Icons.chat, color: Colors.blue),
                                          onPressed: () => _navigateToChat(reservation.user),
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
}
