import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';

class ReservationConfirmationPage extends StatefulWidget {
  final Drive drive;
  final int userId;

  const ReservationConfirmationPage({
    Key? key,
    required this.drive,
    required this.userId,
  }) : super(key: key);

  @override
  _ReservationConfirmationPageState createState() =>
      _ReservationConfirmationPageState();
}

class _ReservationConfirmationPageState
    extends State<ReservationConfirmationPage> {
  final ApiService _apiService = ApiService();
  int selectedSeats = 1;
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    totalPrice = widget.drive.price * selectedSeats;
  }

  void _updateTotalPrice(int seats) {
    setState(() {
      selectedSeats = seats;
      totalPrice = widget.drive.price * selectedSeats;
    });
  }

  Future<void> _confirmReservation() async {
    try {
      await _apiService.createReservation(
        widget.userId,
        widget.drive.id,
        selectedSeats,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation confirmed!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during reservation: $e')),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // Title above the card
              Text(
                'Reservation Confirmation',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20), // Add spacing between title and card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.drive.pickup} → ${widget.drive.destination}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Date and Time: ${widget.drive.deptime}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Select the number of seats',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (selectedSeats > 1) {
                                    _updateTotalPrice(selectedSeats - 1);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                '$selectedSeats',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 15),
                              GestureDetector(
                                onTap: () {
                                  if (selectedSeats < widget.drive.seating) {
                                    _updateTotalPrice(selectedSeats + 1);
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total Price: ${totalPrice.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _confirmReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
