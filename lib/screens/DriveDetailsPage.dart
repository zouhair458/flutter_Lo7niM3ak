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
      final driverDetails =
          await _apiService.fetchDriverById(widget.drive.driverId);

      if (driverDetails != null) {
        setState(() {
          driverFullName =
              '${driverDetails['firstName']} ${driverDetails['name']}';
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
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drive Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildCarDetailsSection() {
    if (widget.drive.car == null) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Make: ${widget.drive.car!.manufacturer}'),
            Text('License Plate: ${widget.drive.car!.licencePlate}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Information',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Name: ${driverFullName ?? 'Loading...'}'),
            Text('Email: ${driverEmail ?? 'Loading...'}'),
            Text('Phone: ${driverPhone ?? 'Loading...'}'),
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
                : const Text('Average Rating: Not Available'),
          ],
        ),
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
        label: const Text('Reserve Drive'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black,
          child: Icon(icon, color: Colors.white),
        ),
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
