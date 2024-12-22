import 'package:flutter/material.dart';
import '../services/ApiService.dart';

class CreateDrivePage extends StatefulWidget {
  final int driverId;

  const CreateDrivePage({super.key, required this.driverId});

  @override
  _CreateDrivePageState createState() => _CreateDrivePageState();
}

class _CreateDrivePageState extends State<CreateDrivePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // List of available cities for Pickup and Destination
  List<String> cities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
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
    'Settat',
    'Sidi Bennour',
    'Mohammedia',
    'Khenifra',
  ];

  String? _pickupLocation;
  String? _destinationLocation;

  final ApiService _apiService = ApiService();

  Future<void> _createDrive() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _apiService.createDrive(
          widget.driverId,
          _pickupLocation ?? '',
          _destinationLocation ?? '',
          _selectedDate,
          double.parse(_priceController.text),
          int.parse(_seatsController.text),
          _descriptionController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drive created successfully!')),
        );
        Navigator.pop(
            context, true); // Return true to signal that a drive was created
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create drive.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Create New Drive',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),

              // Pickup Location Dropdown
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pickup Location',
                      border: InputBorder.none,
                    ),
                    value: _pickupLocation,
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _pickupLocation = newValue;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a pickup location'
                        : null,
                  ),
                ),
              ),

              // Destination Location Dropdown
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Destination Location',
                      border: InputBorder.none,
                    ),
                    value: _destinationLocation,
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _destinationLocation = newValue;
                      });
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select a destination location'
                        : null,
                  ),
                ),
              ),

              // Price input
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Base Price (MAD)',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || double.tryParse(value) == null
                            ? 'Please enter a valid price'
                            : null,
                  ),
                ),
              ),

              // Available Seats input
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _seatsController,
                    decoration: const InputDecoration(
                      labelText: 'Available Seats',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || int.tryParse(value) == null
                            ? 'Please enter a valid number of seats'
                            : null,
                  ),
                ),
              ),

              // Description input
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                ),
              ),

              // Date Picker
              ListTile(
                title: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                    style: const TextStyle(fontSize: 16)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 20),

              // Create Drive Button
              ElevatedButton(
                onPressed: _createDrive,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Drive',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
