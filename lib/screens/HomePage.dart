import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Dashbord.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'SearchResultsPage.dart';
import 'ProfilePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carpooling App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(apiService: ApiService()),
        '/my-reservations': (context) => MyReservationsPage(),
        '/profile': (context) => ProfilePage(), // Define ProfilePage route
        // Add other routes as needed
      },
      onGenerateRoute: (settings) {
        // You can add custom route handling here if needed
        return null;
      },
      onUnknownRoute: (settings) {
        // Handle unknown routes if any
        return MaterialPageRoute(builder: (context) => UnknownPage());
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final ApiService apiService;

  const HomePage({super.key, required this.apiService});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  String? _selectedStartCity;
  String? _selectedEndCity;
  DateTime? _selectedDate;
  int _seats = 1;
  final List<String> _cities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fes',
    'Tangier',
    'Agadir',
    'Tetouan',
    'Oujda',
    'Kenitra',
    'Meknes',
    'Safi',
    'El Jadida',
    'Nador',
    'Khemisset',
    'Settat'
  ];
  int? userId;

  void _searchDrives() {
    if (_selectedStartCity == null ||
        _selectedEndCity == null ||
        _seats <= 0 ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields correctly.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          startLocation: _selectedStartCity!,
          endLocation: _selectedEndCity!,
          date: _selectedDate!,
          seats: _seats,
          userId: userId!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    userId = ModalRoute.of(context)?.settings.arguments as int?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Find Your Perfect Ride',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Dropdown for Start City
              _buildDropdown('Start City', _selectedStartCity, (value) {
                setState(() {
                  _selectedStartCity = value;
                });
              }),

              const SizedBox(height: 20),

              // Dropdown for End City
              _buildDropdown('End City', _selectedEndCity, (value) {
                setState(() {
                  _selectedEndCity = value;
                });
              }),

              const SizedBox(height: 20),

              // Number of Seats
              _buildSeatSelector(),

              const SizedBox(height: 30),

              // Date Picker
              _buildDatePicker(),

              const SizedBox(height: 50),

              // Search Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _searchDrives,
                  icon: const Icon(Icons.search, color: Colors.white),
                  label: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDropdown(
      String label, String? value, ValueChanged<String?> onChanged) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: DropdownButtonFormField<String>(
          value: value,
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.location_on, color: Colors.black),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Number of Seats',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_seats > 1) {
                  setState(() {
                    _seats--;
                  });
                }
              },
              child: _circleButton(Icons.remove),
            ),
            const SizedBox(width: 10),
            Text(
              '$_seats',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _seats++;
                });
              },
              child: _circleButton(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _selectedDate == null
              ? 'Date'
              : 'Date : ${_selectedDate!.toLocal()}'.split(' ')[0],
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.black),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() {
                _selectedDate = pickedDate;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Icon(icon, color: Colors.black),
    );
  }

  void _showBottomSheet(BuildContext context) {
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
              _menuOption(context, Icons.calendar_today, "My Reservations", () {
                Navigator.pushNamed(context, '/my-reservations',
                    arguments: userId);
              }),
              _menuOption(context, Icons.person, "Profile", () {
                Navigator.pushNamed(context, '/profile', arguments: userId);
              }),
              _menuOption(context, Icons.logout, "Logout", () {
                Navigator.pushReplacementNamed(context, '/');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully logged out!'),
                    backgroundColor: Colors.green,
                  ),
                );
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
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

class MyReservationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: const Text('List of reservations will be displayed here.'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: const Text('Profile details go here.'),
      ),
    );
  }
}

class UnknownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: const Text('The page you requested could not be found.'),
      ),
    );
  }
}
