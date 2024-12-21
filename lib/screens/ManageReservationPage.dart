import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ChatPage.dart';
import '../models/reservation_model.dart';
import '../services/ApiService.dart';

class ManageReservationPage extends StatefulWidget {
  final int driveId;
  final String driveDetails;
  final double basePrice;

  const ManageReservationPage({
    Key? key,
    required this.driveId,
    required this.driveDetails,
    required this.basePrice,
  }) : super(key: key);

  @override
  _ManageReservationPageState createState() => _ManageReservationPageState();
}

class _ManageReservationPageState extends State<ManageReservationPage> {
  final ApiService _apiService = ApiService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reservations = await _apiService.getReservationsByDriveId(widget.driveId);
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is SocketException
                ? 'Check your internet connection.'
                : 'Failed to load reservations.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateReservationStatus(int reservationId, String status) async {
    try {
      await _apiService.updateReservationStatus(reservationId, status);
      await _fetchReservations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToChat(int passengerId, String passengerName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          senderId: widget.driveId,
          receiverId: passengerId,
          receiverName: passengerName,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'REFUSED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Reservations (${widget.driveDetails})'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservations.isEmpty
              ? const Center(child: Text('No reservations found.'))
              : ListView.builder(
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    final double totalPrice = widget.basePrice * reservation.seats;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Passenger: ${reservation.user.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('Seats Reserved: ${reservation.seats}'),
                            Text(
                              'Total Price: ${totalPrice.toStringAsFixed(2)} MAD',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Status: ${reservation.status}',
                              style: TextStyle(
                                color: _getStatusColor(reservation.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (reservation.status == 'PENDING')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _updateReservationStatus(
                                      reservation.id,
                                      'ACCEPTED',
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _updateReservationStatus(
                                      reservation.id,
                                      'REFUSED',
                                    ),
                                  ),
                                ],
                              ),
                            if (reservation.status == 'ACCEPTED')
                              ElevatedButton(
                                onPressed: () {
                                  _navigateToChat(
                                    reservation.user.id,
                                    reservation.user.name,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text('Chat'),
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
