import 'package:flutter/material.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';

class DriveDetailsPage extends StatefulWidget {
  final Drive drive;

  const DriveDetailsPage({Key? key, required this.drive}) : super(key: key);

  @override
  _DriveDetailsPageState createState() => _DriveDetailsPageState();
}

class _DriveDetailsPageState extends State<DriveDetailsPage> {
  String? driverFullName; // Pour stocker le nom complet du conducteur
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Vérification initiale si les informations du conducteur sont déjà présentes dans `widget.drive`
    if (widget.drive.user.firstName != 'Unknown' &&
        widget.drive.user.name != 'Unknown') {
      driverFullName =
          '${widget.drive.user.firstName} ${widget.drive.user.name}';
    } else {
      _fetchDriverDetails(); // Appeler l'API si les informations sont manquantes
    }
  }

  Future<void> _fetchDriverDetails() async {
  try {
    final driverDetails =
        await _apiService.fetchDriverById(widget.drive.user.id);
    
    if (driverDetails != null) {
      setState(() {
        driverFullName =
            '${driverDetails['firstName'] ?? 'Unknown'} ${driverDetails['name'] ?? 'Unknown'}';
      });
    } else {
      setState(() {
        driverFullName = 'Unknown Driver'; // Gestion des données manquantes
      });
    }
  } catch (e) {
    setState(() {
      driverFullName = 'Unknown Driver'; // Gestion des erreurs d'API
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DetailItem(
              title: widget.drive.pickup,
              subtitle: 'Departure City',
            ),
            const SizedBox(height: 10),
            DetailItem(
              title: widget.drive.destination,
              subtitle: 'Arrival City',
            ),
            const SizedBox(height: 10),
            DetailItem(
              title: widget.drive.deptime.toLocal().toString(),
              subtitle: 'Date & Time',
            ),
            const SizedBox(height: 10),
            DetailItem(
              title: '${widget.drive.seating}',
              subtitle: 'Seats',
            ),
            const SizedBox(height: 10),
            DetailItem(
              title: '${widget.drive.price.toStringAsFixed(2)} MAD',
              subtitle: 'Price',
            ),
            const SizedBox(height: 10),
            DetailItem(
              title: widget.drive.description,
              subtitle: 'Description',
            ),
            const SizedBox(height: 10),
            // Affichage du nom du conducteur ou "Loading..." si l'API n'a pas encore renvoyé les données
            DetailItem(
              title: driverFullName ?? 'Loading...',
              subtitle: 'Driver Name',
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const DetailItem({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
