import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  final bool isDriver;
  final int userId;

  const DashboardWidget(
      {Key? key, required this.isDriver, required this.userId})
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
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _menuOption(context, Icons.chat, "My Conversations", () {
                Navigator.pushNamed(context, '/my-conversations',
                    arguments: userId);
              }),
              _menuOption(context, Icons.calendar_today, "My Reservations", () {
                Navigator.pushNamed(context, '/my-reservations',
                    arguments: userId);
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

  Widget _menuOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 0, 0, 0)),
      title: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully logged out!'),
      backgroundColor: Colors.green,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () => _showMenu(context),
        icon: const Icon(
          Icons.menu, // Hamburger menu icon
          color: Color.fromARGB(255, 0, 0, 0),
          size: 30,
        ),
        color: const Color.fromARGB(255, 0, 0, 0), // Button color
        iconSize: 40, // Adjust size
      ),
    );
  }
}
