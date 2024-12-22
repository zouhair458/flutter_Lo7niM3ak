import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/ChatPage.dart';
import 'package:flutter_application_1/screens/DriverHomePage.dart';
import 'package:flutter_application_1/screens/HomePage.dart';
import 'package:flutter_application_1/screens/ProfilePage.dart';
import 'package:flutter_application_1/screens/login_page.dart';
import 'package:flutter_application_1/screens/MyConversationsPage.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  Stripe.publishableKey =
      'pk_test_51PlWAM2K4zodnfhoZ3zs40ews5kf6ejRCvp3XYW7ehFHS8BtvrNmtczoUrptxr1Wdks5JzBd6Pxss43mUOI9peZK00UIWobYKl';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covoiturage - Lo7ni M3ak',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(apiService: ApiService()),
        '/homepage': (context) => HomePage(apiService: ApiService()),
        '/driverpage': (context) => DriverHomePage(
              driverId: ModalRoute.of(context)?.settings.arguments as int,
            ),
        '/profile': (context) => ProfilePage(
              userId: ModalRoute.of(context)?.settings.arguments as int,
              apiService: ApiService(),
            ),
        '/my-conversations': (context) => MyConversationsPage(
              userId: ModalRoute.of(context)?.settings.arguments as int,
            ),
        '/chat': (context) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args == null || args['senderId'] == null || args['receiverId'] == null || args['receiverName'] == null) {
    throw Exception('Invalid arguments for /chat route. Ensure senderId, receiverId, and receiverName are provided.');
  }

  return ChatPage(
    senderId: args['senderId'],
    receiverId: args['receiverId'],
    receiverName: args['receiverName'],
  );
},
   
      },
    );
  }
}
