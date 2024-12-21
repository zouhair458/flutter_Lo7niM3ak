class Car {
  final String manufacturer;
  final String model;
  final int numberOfSeats;
  final String color;
  final String licencePlate;

  Car({
    required this.manufacturer,
    required this.model,
    required this.numberOfSeats,
    required this.color,
    required this.licencePlate,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      numberOfSeats: json['number_of_seats'] ?? 0,
      color: json['color'] ?? '',
      licencePlate: json['licence_plate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manufacturer': manufacturer,
      'model': model,
      'number_of_seats': numberOfSeats,
      'color': color,
      'licence_plate': licencePlate,
    };
  }
}
