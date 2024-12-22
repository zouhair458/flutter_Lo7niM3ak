import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/services/ApiService.dart';

class ReviewPage extends StatefulWidget {
  final int? userId;
  final int reservationId;

  const ReviewPage(
      {Key? key, required this.userId, required this.reservationId})
      : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _rating = 0;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please provide a rating")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService()
          .createReview(widget.userId!, _rating, _messageController.text);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Review submitted successfully!")));

      // Navigate to the HomePage and pass the ApiService as a required parameter
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            apiService: ApiService(), // Pass the ApiService here
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to submit review: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Leave a Review'),
      content: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate the Driver",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
                Text("Write a Comment",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _messageController,
                  decoration:
                      InputDecoration(hintText: "Share your experience..."),
                  maxLines: 3,
                ),
                ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Submit'),
                ),
              ],
            ),
    );
  }
}
