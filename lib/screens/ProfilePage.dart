import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/models/review_model.dart';
import 'package:flutter_application_1/models/car_model.dart';
import 'package:flutter_application_1/services/ApiService.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final ApiService apiService;

  const ProfilePage({super.key, required this.userId, required this.apiService});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  List<Review> _reviews = [];
  List<Car> _cars = [];
  bool _isLoading = true;

  final TextEditingController _fabricantController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userData = await widget.apiService.fetchUserById(widget.userId);
      final userReviews = await widget.apiService.fetchUserReviews(widget.userId);
      List<Car> userCars = [];

      if (userData['role'] == 'Driver') {
        final carData = await widget.apiService.fetchUserCars(widget.userId);
        userCars = carData.map((car) => Car.fromJson(car)).toList();
      }

      setState(() {
        _user = User.fromJson(userData);
        _reviews = userReviews.map((reviewJson) => Review.fromJson(reviewJson)).toList();
        _cars = userCars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load user data: $e")),
      );
    }
  }

  Future<void> _updateRole(bool isDriver) async {
    final newRole = isDriver ? 'Driver' : 'Passenger';
    try {
      await widget.apiService.updateUserRole(_user!.email, newRole);
      setState(() {
        _user!.role = newRole;
      });

      if (isDriver) {
        final carData = await widget.apiService.fetchUserCars(widget.userId);
        setState(() {
          _cars = carData.map((car) => Car.fromJson(car)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update role: $e")),
      );
    }
  }

  Future<void> _addCar() async {
    final carData = {
      'manufacturer': _fabricantController.text,
      'model': _modelController.text,
      'number_of_seats': int.parse(_seatsController.text),
      'color': _colorController.text,
      'licence_plate': _plateController.text,
      'userId': widget.userId,
    };

    try {
      await widget.apiService.addCar(carData);
      final carList = await widget.apiService.fetchUserCars(widget.userId);
      setState(() {
        _cars = carList.map((car) => Car.fromJson(car)).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Car added successfully")),
      );

      // Clear form fields after successful addition
      _fabricantController.clear();
      _modelController.clear();
      _seatsController.clear();
      _colorController.clear();
      _plateController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add car: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading || _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nom: ${_user!.firstName}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Email: ${_user!.email}", style: const TextStyle(fontSize: 16)),
                          Text("Téléphone: ${_user!.phone}", style: const TextStyle(fontSize: 16)),
                          SwitchListTile(
                            title: Text("Rôle: ${_user!.role}"),
                            value: _user!.role == 'Driver',
                            onChanged: (value) async {
                              await _updateRole(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_user!.role == 'Driver' || _user!.role == 'Passenger') ...[
                    const SizedBox(height: 16),
                    const Text("Mes Avis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_reviews.isNotEmpty) ...[
                      for (var review in _reviews)
                      Card(
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(review.note.toString(), style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text("Note: ${review.note}"),
                            subtitle: Text("Commentaire: ${review.message}"),
                            trailing: Text("Par: ${_user!.firstName}"),
                            ),
                            ),
                            ] else ...[
                              const Text("Aucun avis trouvé.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                              ],
                    if (_user!.role == 'Driver') ...[
                    const Text("Ajouter une Voiture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextField(_fabricantController, "Fabricant"),
                    _buildTextField(_modelController, "Modèle"),
                    _buildTextField(_seatsController, "Nombre de sièges", isNumeric: true),
                    _buildTextField(_colorController, "Couleur"),
                    _buildTextField(_plateController, "Plaque d'immatriculation"),
                    ElevatedButton(
                      onPressed: _addCar,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text("Ajouter"),
                    ),
                    const SizedBox(height: 20),
                    const Text("Mes Voitures", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    for (var car in _cars)
                      Card(
                        elevation: 4,
                        child: ListTile(
                          title: Text("${car.manufacturer} ${car.model}"),
                          subtitle: Text("Couleur: ${car.color}, Sièges: ${car.numberOfSeats}"),
                        ),
                      ),
                  ],

                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
