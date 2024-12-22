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
  double? avgNote;
  List<dynamic>? reviews;

  @override
  void initState() {
    super.initState();
    fetchDriverDetails();
  }

  Future<void> fetchDriverDetails() async {
    try {
      final fetchedAvgNote =
          await _apiService.getAverageNoteByDriverId(widget.driver.id);
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
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child:
                      const Icon(Icons.person, size: 60, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "${widget.driver.firstName} ${widget.driver.name}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (avgNote != null)
                Center(
                  child: Text(
                    "Average Rating: ${avgNote!.toStringAsFixed(1)} ⭐",
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Driver Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildDetailTile("Email", widget.driver.email),
              _buildDetailTile("Phone", widget.driver.phone),
              _buildDetailTile("Role", widget.driver.role),
              const SizedBox(height: 20),
              const Divider(),
              const Text(
                "Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              if (reviews != null && reviews!.isNotEmpty)
                ...reviews!.map((review) => _buildReviewTile(review))
              else
                const Text(
                  "No reviews available for this driver.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(dynamic review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rating: ${review['note']} ⭐",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review['message'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
