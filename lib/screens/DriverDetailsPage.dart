import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/ApiService.dart';

class DriverDetailsPage extends StatefulWidget {
  final User driver;

  const DriverDetailsPage({super.key, required this.driver});

  @override
  _DriverDetailsPageState createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  final ApiService _apiService = ApiService();
  double? avgNote; // To store the average note
  List<dynamic>? reviews; // To store reviews for the driver

  @override
  void initState() {
    super.initState();
    fetchDriverDetails();
  }

  Future<void> fetchDriverDetails() async {
    try {
      // Fetch average note
      final fetchedAvgNote =
          await _apiService.getAverageNoteByDriverId(widget.driver.id);

      // Fetch reviews
      final fetchedReviews =
          await _apiService.fetchUserReviews(widget.driver.id);

      setState(() {
        avgNote = fetchedAvgNote;
        reviews = fetchedReviews;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch driver details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Details"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                "${widget.driver.firstName} ${widget.driver.name}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (avgNote != null)
                Text(
                  "Average Rating: ${avgNote!.toStringAsFixed(1)} ⭐",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              const SizedBox(height: 20),
              _buildDetailTile("Email", widget.driver.email),
              _buildDetailTile("Phone", widget.driver.phone),
              _buildDetailTile("Role", widget.driver.role),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Reviews",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (reviews != null && reviews!.isNotEmpty)
                ...reviews!.map((review) => _buildReviewTile(review))
              else
                const Text("No reviews available for this driver."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildReviewTile(dynamic review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          "Rating: ${review['note']} ⭐",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(review['message']),
      ),
    );
  }
}
