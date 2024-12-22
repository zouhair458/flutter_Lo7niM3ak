import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/reservation_model.dart';
import 'package:flutter_application_1/services/reservation_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

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
    setState(() => isLoading = true);

    try {
      final clientSecret =
          await widget.reservationService.createPaymentIntent(reservation.id);

      if (clientSecret != null) {
        await stripe.Stripe.instance.initPaymentSheet(
          paymentSheetParameters: stripe.SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Lo7niM3ak',
          ),
        );
        await stripe.Stripe.instance.presentPaymentSheet();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful for reservation ${reservation.id}')),
        );
        _loadReservations(); // Refresh reservations
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reservations")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : _reservationsList.isEmpty
                  ? const Center(child: Text('No reservations found.'))
                  : ListView.builder(
                      itemCount: _reservationsList.length,
                      itemBuilder: (context, index) {
                        var reservation = _reservationsList[index];
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              '${reservation.drive?.pickup} → ${reservation.drive?.destination}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Date: ${reservation.drive?.deptime.toLocal().toString().substring(0, 16)}\n'
                              'Seats: ${reservation.seats}\n'
                              'Total Price: MAD ${reservation.drive!.price * reservation.seats}\n'
                              'Status: ${reservation.status}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: reservation.status == 'ACCEPTED'
                                ? ElevatedButton(
                                    onPressed: () => _proceedToPayment(reservation),
                                    child: const Text('Pay'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}
