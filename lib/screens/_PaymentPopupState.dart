import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/reservation_model.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_application_1/services/reservation_service.dart';

class PaymentPopup extends StatefulWidget {
  final Reservation reservation;
  final ReservationService reservationService;

  PaymentPopup({required this.reservation, required this.reservationService});

  @override
  _PaymentPopupState createState() => _PaymentPopupState();
}

class _PaymentPopupState extends State<PaymentPopup> {
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      final clientSecret = await widget.reservationService
          .createPaymentIntent(widget.reservation.id);

      if (clientSecret != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Lo7niM3ak',
            style: ThemeMode.light,
          ),
        );

        await Stripe.instance.presentPaymentSheet();
        Navigator.pop(context, true); // Close the popup after success
      } else {
        setState(() {
          errorMessage = 'Error fetching client secret.';
        });
      }
    } catch (e) {
      print('Payment initialization error: $e');
      setState(() {
        errorMessage = 'Payment canceled or failed. Reason: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Paiement par Carte Bancaire'),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Text(errorMessage, style: TextStyle(color: Colors.red))
              : Text('Le paiement a été effectué avec succès.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: Text('Annuler'),
        ),
      ],
    );
  }
}