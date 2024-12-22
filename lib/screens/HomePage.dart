import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Dashbord.dart';
import 'package:flutter_application_1/services/ApiService.dart';
import 'SearchResultsPage.dart';

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
  List<String> _startCities = [];
  List<String> _endCities = [];
  int? userId;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final drives = await _apiService.fetchAllDrives();
      setState(() {
        _startCities = drives.map((drive) => drive['pickup']).toSet().cast<String>().toList();
        _endCities = drives.map((drive) => drive['destination']).toSet().cast<String>().toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Offers',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0075FD),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Dropdown for Start City
              DropdownButtonFormField<String>(
                value: _selectedStartCity,
                items: _startCities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStartCity = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Start City',
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0075FD)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0075FD), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown for End City
              DropdownButtonFormField<String>(
                value: _selectedEndCity,
                items: _endCities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEndCity = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'End City',
                  prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0075FD)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF0075FD), width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Number of Seats
              Row(
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
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0075FD), width: 2),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Color(0xFF0075FD),
                          ),
                        ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF0075FD), width: 2),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Color(0xFF0075FD),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? 'Date'
                        : 'Date : ${_selectedDate!.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF0075FD)),
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
              ),
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
                    backgroundColor: const Color(0xFF0075FD),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (userId != null) DashboardWidget(isDriver: false, userId: userId!),
            ],
          ),
        ),
      ),
    );
  }
}
