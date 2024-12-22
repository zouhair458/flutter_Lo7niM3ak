import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';
import 'DriveDetailsPage.dart';
import 'ReservationConfirmationPage.dart';

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
        final dateMatches = drive.deptime
                .isAfter(widget.date.subtract(const Duration(days: 1))) &&
            drive.deptime.isBefore(widget.date.add(const Duration(days: 1)));
        final seatsMatches = drive.seating >= widget.seats;

        return pickupMatches &&
            destinationMatches &&
            dateMatches &&
            seatsMatches;
      }).toList();
    });
  }

  void _showDashboardMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuOption(context, Icons.chat, "Mes Conversations", () {
                Navigator.pushNamed(context, '/my-conversations',
                    arguments: widget.userId);
              }),
              _menuOption(context, Icons.calendar_today, "Mes Réservations",
                  () {
                Navigator.pushNamed(context, '/my-reservations',
                    arguments: widget.userId);
              }),
              _menuOption(context, Icons.person, "Profil", () {
                Navigator.pushNamed(context, '/profile',
                    arguments: widget.userId);
              }),
              _menuOption(context, Icons.logout, "Déconnexion", () {
                Navigator.pushReplacementNamed(context, '/');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Déconnecté avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _menuOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _filterDrives();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultats',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              '${drive.pickup} → ${drive.destination}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${drive.price.toStringAsFixed(2)} MAD',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF4CAF50),
                              ),
                            ),
                            onTap: () {
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
                            padding: const EdgeInsets.all(12.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationConfirmationPage(
                                        drive: drive,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDashboardMenu,
        backgroundColor: Colors.black,
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
