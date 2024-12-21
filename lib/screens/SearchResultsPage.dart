import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';
import 'DriveDetailsPage.dart'; // Import de la page des détails
import 'ReservationConfirmationPage.dart'; // Import de la page de confirmation

class SearchResultsPage extends StatefulWidget {
  final String startLocation;
  final String endLocation;
  final DateTime date;
  final int seats;
  final int userId;

  const SearchResultsPage({
    required this.startLocation,
    required this.endLocation,
    required this.date,
    required this.seats,
    required this.userId,
    super.key,
  });

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ApiService _apiService = ApiService();
  List<Drive> _drives = [];
  List<Drive> _filteredDrives = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDrives();
  }

  Future<void> _fetchDrives() async {
    try {
      List<dynamic> drives = await _apiService.fetchAllDrives();
      setState(() {
        _drives = drives.map((drive) => Drive.fromJson(drive)).toList();
        _filteredDrives = List.from(_drives);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la récupération des données.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterDrives() {
    setState(() {
      _filteredDrives = _drives.where((drive) {
        final pickupMatches = drive.pickup
            .toLowerCase()
            .contains(widget.startLocation.toLowerCase());
        final destinationMatches = drive.destination
            .toLowerCase()
            .contains(widget.endLocation.toLowerCase());
        final dateMatches =
            drive.deptime.isAfter(widget.date.subtract(const Duration(days: 1))) &&
                drive.deptime.isBefore(widget.date.add(const Duration(days: 1)));
        final seatsMatches = drive.seating >= widget.seats;

        return pickupMatches &&
            destinationMatches &&
            dateMatches &&
            seatsMatches;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _filterDrives();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredDrives.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun trajet trouvé pour cette recherche.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredDrives.length,
                  itemBuilder: (context, index) {
                    final drive = _filteredDrives[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              '${drive.pickup} -> ${drive.destination}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${drive.price.toStringAsFixed(2)} MAD',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                            onTap: () {
                              // Naviguer vers DriveDetailsPage avec l'objet drive
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DriveDetailsPage(
                                    drive: drive,
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Naviguer vers ReservationConfirmationPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationConfirmationPage(
                                        drive: drive, // Passer l'objet drive
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Réserver',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
