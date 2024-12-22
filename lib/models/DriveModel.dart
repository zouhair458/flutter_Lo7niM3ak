import 'user_model.dart';

class Drive {
  final int id;
  final String pickup;
  final String destination;
  final DateTime deptime;
  final double price;
  final int seating;
  final String description;
  final int driverId; // Equivalent to `driverId` in Angular
  final User? driver; // Optional driver, equivalent to `driver` in Angular
  final double? avgNote; // Optional avgNote
  final Car? car; // Optional car details

  Drive({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.deptime,
    required this.price,
    required this.seating,
    required this.description,
    required this.driverId,
    this.driver,
    this.avgNote,
    this.car,
  });

  factory Drive.fromJson(Map<String, dynamic> json) {
    return Drive(
      id: json['id'] ?? 0,
      pickup: json['pickup'] ?? '',
      destination: json['destination'] ?? '',
      deptime: DateTime.parse(json['deptime'] ?? DateTime.now().toString()),
      price: json['price']?.toDouble() ?? 0.0,
      seating: json['seating'] ?? 0,
      description: json['description'] ?? '',
      driverId: json['driverId'] ?? 0, // Map `driverId` field
      driver: json['driver'] != null ? User.fromJson(json['driver']) : null, // Optional driver
      avgNote: json['avgNote']?.toDouble(), // Optional avgNote
      car: json['car'] != null ? Car.fromJson(json['car']) : null, // Optional car
    );
  }

  get driverName => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup': pickup,
      'destination': destination,
      'deptime': deptime.toIso8601String(),
      'price': price,
      'seating': seating,
      'description': description,
      'driverId': driverId,
      'driver': driver?.toJson(), // Include driver if available
      'avgNote': avgNote,
      'car': car?.toJson(), // Include car details if available
    };
  }
}

class Car {
  final String manufacturer;
  final String model;
  final String licencePlate;

  Car({
    required this.manufacturer,
    required this.model,
    required this.licencePlate,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      licencePlate: json['licence_plate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'licence_plate': licencePlate,
    };
  }
}
