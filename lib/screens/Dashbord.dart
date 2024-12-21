import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/reservation_page.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'package:flutter_application_1/services/reservation_service.dart';

class DashboardWidget extends StatelessWidget {
  final bool isDriver;
  final int userId;

  const DashboardWidget({Key? key, required this.isDriver, required this.userId})
      : super(key: key);

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuOption(context, Icons.chat, "My Conversations", () {
                Navigator.pushNamed(context, '/my-conversations',
                    arguments: userId);
              }),
              if (isDriver)
                _menuOption(context, Icons.local_offer, "My Offers", () {
                  Navigator.pushNamed(context, '/driverpage', arguments: userId);
                }),
              _menuOption(context, Icons.calendar_today, "My Reservations", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReservationPage(
                      userId: userId,
                      reservationService:
                          ReservationService(ApiService()), // Inject the service
                    ),
                  ),
                );
              }),
              _menuOption(context, Icons.person, "Profile", () {
                Navigator.pushNamed(context, '/profile', arguments: userId);
              }),
              _menuOption(context, Icons.logout, "Logout", () {
                _logout(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _menuOption(BuildContext context, IconData icon, String title,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully logged out!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            leading: Icon(Icons.dashboard, color: Colors.blue),
            title: Text(
              "Dashboard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Welcome to the Lo7niM3ak Dashboard!"),
          ),
          TextButton.icon(
            onPressed: () => _showMenu(context),
            icon: const Icon(Icons.menu, color: Colors.blue),
            label: const Text("Open Menu"),
          ),
        ],
      ),
    );
  }
}
