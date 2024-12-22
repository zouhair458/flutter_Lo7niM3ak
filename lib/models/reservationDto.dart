class ReservationDto {
  final int id;
  final int seats;
  final int? driveId;
  final int? userId;
  final String? status;

  ReservationDto({
    required this.id,
    required this.seats,
    this.driveId,
    this.userId,
    this.status,
  });

  factory ReservationDto.fromJson(Map<String, dynamic> json) {
    return ReservationDto(
      id: json['id'] ?? 0,
      seats: json['seats'] ?? 0,
      driveId: json['driveId'] as int?,
      userId: json['userId'] as int?,
      status: json['status'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seats': seats,
      'driveId': driveId,
      'userId': userId,
      'status': status,
    };
  }
}
