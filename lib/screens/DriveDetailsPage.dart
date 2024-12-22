import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/DriveModel.dart';
import '../services/ApiService.dart';

class DriveDetailsPage extends StatefulWidget {
  final Drive drive;

  const DriveDetailsPage({Key? key, required this.drive}) : super(key: key);

  @override
  _DriveDetailsPageState createState() => _DriveDetailsPageState();
}

class _DriveDetailsPageState extends State<DriveDetailsPage> {
  String? driverFullName;
  String? driverEmail;
  String? driverPhone;
  double? avgNote;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchDriverDetails();
  }

  Future<void> _fetchDriverDetails() async {
    try {
      final driverDetails = await _apiService.fetchDriverById(widget.drive.driverId);

      if (driverDetails != null) {
        setState(() {
          driverFullName = '${driverDetails['firstName']} ${driverDetails['name']}';
          driverEmail = driverDetails['email'];
          driverPhone = driverDetails['phone'];
          avgNote = driverDetails['avgNote']?.toDouble();
        });
      } else {
        _setUnknownDriver();
      }
    } catch (e) {
      _setUnknownDriver();
    }
  }

  void _setUnknownDriver() {
    setState(() {
      driverFullName = 'Unknown Driver';
      driverEmail = 'Not Available';
      driverPhone = 'Not Available';
      avgNote = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drive Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailsSection(),
            const SizedBox(height: 20),
            _buildCarDetailsSection(),
            const SizedBox(height: 20),
            _buildDriverInfoSection(),
            const SizedBox(height: 20),
            _buildReserveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailItem(
          icon: Icons.info,
          title: widget.drive.description,
          subtitle: 'Description',
        ),
        DetailItem(
          icon: FontAwesomeIcons.coins,
          title: '${widget.drive.price.toStringAsFixed(2)} MAD',
          subtitle: 'Price',
        ),
        DetailItem(
          icon: Icons.people,
          title: 'Places disponibles: ${widget.drive.seating}',
          subtitle: 'Seats',
        ),
        DetailItem(
          icon: Icons.calendar_today,
          title: 'Date de départ: ${widget.drive.deptime.toLocal()}',
          subtitle: 'Departure Date',
        ),
      ],
    );
  }

  Widget _buildCarDetailsSection() {
    if (widget.drive.car == null) {
      return const SizedBox.shrink();
    }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations sur la voiture',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text('La marque: ${widget.drive.car!.manufacturer}'),
          Text('Immatriculation: ${widget.drive.car!.licencePlate}'),
        ],
      ),
    );
  }

  Widget _buildDriverInfoSection() {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du conducteur',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text('Nom: ${driverFullName ?? 'Loading...'}'),
          Text('Email: ${driverEmail ?? 'Loading...'}'),
          Text('Téléphone: ${driverPhone ?? 'Loading...'}'),
          const SizedBox(height: 8),
          avgNote != null
              ? Row(
                  children: [
                    Text(
                      '⭐ ${avgNote!.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : const Text('Note Moyenne: Non disponible'),
        ],
      ),
    );
  }

  Widget _buildReserveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement reservation logic
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('Réserver ce trajet'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DetailItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(width: 10),
        Expanded(
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
        ),
      ],
    );
  }
}
