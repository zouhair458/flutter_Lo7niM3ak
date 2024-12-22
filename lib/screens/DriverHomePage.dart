import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Dashbord.dart';
import 'package:intl/intl.dart'; // Pour formater les dates
import '../services/ApiService.dart';
import '../models/DriveModel.dart';
import 'OfferDetailsPage.dart'; // Import de ManageReservationPage
import 'CreateDrivePage.dart';

class DriverHomePage extends StatefulWidget {
  final int driverId; // ID du driver connecté

  const DriverHomePage({super.key, required this.driverId});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final ApiService _apiService = ApiService();
  List<Drive> _drives = []; // Liste des drives
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _fetchDrives(); // Récupère les drives lors de l'initialisation
  }

  // Fonction pour récupérer les drives
  Future<void> _fetchDrives() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final drives = await _apiService.getDrivesByDriver(widget.driverId);
      setState(() {
        _drives = drives;
        _isLoading = false;
      });

      if (drives.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No drives found for this driver.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching drives: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Formate une DateTime en chaîne lisible
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Ajoutez votre widget Dashboard ici
          DashboardWidget(isDriver: true, userId: widget.driverId),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _drives.isEmpty
                    ? const Center(child: Text('No drives available.'))
                    : ListView.builder(
                        itemCount: _drives.length,
                        itemBuilder: (context, index) {
                          final drive = _drives[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OfferDetailsPage(
                                    driveId: drive.id,
                                    driveDetails:
                                        '${drive.pickup} → ${drive.destination}',
                                    basePrice: drive.price,
                                    driverId: widget.driverId,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
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
                                      'Departs at: ${_formatDateTime(drive.deptime)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Seats available: ${drive.seating}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      'Price: ${drive.price} MAD',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateDrivePage(driverId: widget.driverId),
            ),
          );

          if (result != null && result) {
            _fetchDrives();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
