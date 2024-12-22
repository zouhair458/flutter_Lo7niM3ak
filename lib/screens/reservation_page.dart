import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/reservation_model.dart';
import 'package:flutter_application_1/screens/ReviewPage.dart';
import 'package:flutter_application_1/services/reservation_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'Dashbord.dart'; // Ensure this import is correct

class ReservationPage extends StatefulWidget {
  final int userId;
  final ReservationService reservationService;

  const ReservationPage({
    Key? key,
    required this.userId,
    required this.reservationService,
  }) : super(key: key);

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Reservation> _reservationsList = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    widget.reservationService
        .getReservations(widget.userId)
        .then((reservations) {
      setState(() {
        _reservationsList = reservations;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        errorMessage = 'Error loading reservations: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

Future<void> _proceedToPayment(Reservation reservation) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final clientSecret =
          await widget.reservationService.createPaymentIntent(reservation.id);

      if (clientSecret != null) {
        // Initialize Stripe Payment Sheet
        await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Lo7niM3ak',
            style: ThemeMode.light,
          ),
        );

        // Present the Stripe Payment Sheet
        await stripe.Stripe.instance.presentPaymentSheet();

        // On successful payment, navigate to ReviewPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewPage(
              userId: widget.userId, // Pass the userId
              reservationId: reservation.id, // Pass the reservationId
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful for reservation ${reservation.id}.'),
            backgroundColor: Colors.green,
          ),
        );

        _loadReservations(); // Reload reservations after successful payment
      } else {
        throw Exception('Error retrieving client_secret.');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Payment failed: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Colors.green;
      case 'REFUSED':
        return Colors.red;
      case 'CANCELED':
        return Colors.grey;
      case 'PENDING':
        return Colors.orange;
      case 'PAY':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'My Reservations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _reservationsList.isEmpty
                          ? const Center(
                              child: Text(
                                'No reservations found.',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: _reservationsList.length,
                                itemBuilder: (context, index) {
                                  var reservation = _reservationsList[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${reservation.drive?.pickup} → ${reservation.drive?.destination}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Date: ${reservation.drive?.deptime.toLocal().toString().substring(0, 16)}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Seats: ${reservation.seats}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Total Price: MAD ${reservation.drive!.price * reservation.seats}',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Status: ${reservation.status}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: _getStatusColor(
                                                    reservation.status)),
                                          ),
                                          const SizedBox(height: 12),
                                          if (reservation.status == 'ACCEPTED')
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    _proceedToPayment(
                                                        reservation),
                                                child: const Text('Pay'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: DashboardWidget(
              isDriver: true,
              userId: widget.userId,
            ),
          ),
        ],
      ),
    );
  }
}
