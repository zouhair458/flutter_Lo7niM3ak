import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/OfferDetailsPage.dart';
import 'package:intl/intl.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';

class MyOffersPage extends StatefulWidget {
  final int userId;
  final String role; // Can be "Driver" or "Passenger"

  const MyOffersPage({Key? key, required this.userId, required this.role}) : super(key: key);

  @override
  _MyOffersPageState createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  final ApiService _apiService = ApiService();
  List<Drive> _drives = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Drive>? drives;
      if (widget.role == "Driver") {
        // Get the offers created by the driver
        drives = await _apiService.getDrivesByDriver(widget.userId);
      } else {
        // Get the available offers for passengers
        drives = (await _apiService.fetchAllDrives()).cast<Drive>(); // Replace with API for passengers
      }

      setState(() {
        _drives = (drives?..sort((a, b) => b.deptime.compareTo(a.deptime)))!; // Sort by descending date
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading offers: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToOfferDetails(Drive drive) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OfferDetailsPage(
          driveId: drive.id,
          driveDetails: '${drive.destination} → ${drive.pickup}', // Reverse the order
          basePrice: drive.price,
          driverId: drive.driverId ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(child: Text('An error occurred. Please try again later.'))
              : _drives.isEmpty
                  ? const Center(child: Text('No offers available.'))
                  : ListView.builder(
                      itemCount: _drives.length,
                      itemBuilder: (context, index) {
                        final drive = _drives[index];
                        return GestureDetector(
                          onTap: () => _navigateToOfferDetails(drive),
                          child: Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${drive.destination} → ${drive.pickup}', // Reverse the order here
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Departure: ${DateFormat('dd/MM/yyyy HH:mm').format(drive.deptime)}'),
                                  Text('Price: ${drive.price.toStringAsFixed(2)} MAD'),
                                  Text('Seats Available: ${drive.seating}'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
