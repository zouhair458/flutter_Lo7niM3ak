import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import '../services/ApiService.dart';
import '../models/DriveModel.dart';
import 'Dashbord.dart';
import 'OfferDetailsPage.dart'; // Import for OfferDetailsPage
import 'CreateDrivePage.dart'; // Import for CreateDrivePage

class DriverHomePage extends StatefulWidget {
  final int driverId;
  const DriverHomePage({super.key, required this.driverId});

  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final ApiService _apiService = ApiService();
  List<Drive> _drives = []; // List of available drives
  bool _isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchDrives(); // Fetch drives when initializing the page
  }

  // Function to fetch the drives
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

  // Format DateTime as a readable string
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0, // Remove shadow from app bar
      ),
      body: Column(
        children: [
          // Title above the list of cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Offers', // Title text
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _drives.isEmpty
                    ? const Center(child: Text('No drives available.'))
                    : ListView.builder(
                        itemCount: _drives.length,
                        itemBuilder: (context, index) {
                          final drive = _drives.reversed
                              .toList()[index]; // Reversed order
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OfferDetailsPage(
                                    driveId: drive.id,
                                    driveDetails:
                                        '${drive.destination} → ${drive.pickup}', // Reversed order
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
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 6, // Added shadow for better styling
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pickup → Destination at the top of the card
                                    Text(
                                      '${drive.pickup} → ${drive.destination}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Departs at: ${_formatDateTime(drive.deptime)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Seats available: ${drive.seating}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Price: ${drive.price} MAD',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.green),
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 100, // Adjust this to position the FAB above the Dashboard
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateDrivePage(driverId: widget.driverId),
                  ),
                );

                if (result != null && result) {
                  _fetchDrives();
                }
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.transparent, // Removed background color
              elevation: 0, // Optionally remove shadow
            ),
          ),
          Positioned(
            bottom: 10, // Position the Dashboard below the button
            left: 340, // Adjust the position to your preference
            child: DashboardWidget(
              isDriver: true,
              userId: widget.driverId,
            ),
          ),
        ],
      ),
    );
  }
}
