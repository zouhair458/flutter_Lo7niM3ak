import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart'; // Import your ApiService

class ReservationConfirmationPage extends StatefulWidget {
  final Drive drive; // Les informations du covoiturage
  final int userId; // ID de l'utilisateur connecté

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
  final ApiService _apiService = ApiService(); // Initialize ApiService
  int selectedSeats = 1; // Le nombre de sièges sélectionné par le passager
  double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Initialiser le prix total en fonction du nombre de sièges
    totalPrice = widget.drive.price * selectedSeats;
  }

  // Met à jour le prix total en fonction du nombre de sièges
  void _updateTotalPrice(int seats) {
    setState(() {
      selectedSeats = seats;
      totalPrice = widget.drive.price * selectedSeats;
    });
  }

  // Confirmer la réservation
  Future<void> _confirmReservation() async {
    try {
      // Call the API to create the reservation
      await _apiService.createReservation(
        widget.userId, // User ID passed to the page
        widget.drive.id, // Drive ID
        selectedSeats, // Number of seats reserved
      );

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation confirmée!')),
      );

      // Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la réservation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation de Réservation'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
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
                        '${widget.drive.pickup} -> ${widget.drive.destination}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Date et Heure : ${widget.drive.deptime}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Sélectionnez le nombre de sièges',
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
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                '$selectedSeats',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
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
                                        color: Colors.blue, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Prix total: ${totalPrice.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _confirmReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Confirmer',
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
