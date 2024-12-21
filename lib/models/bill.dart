class Bill {
  final dynamic id;
  final dynamic totalAmount;
  final dynamic paid;
  final String billReference;
  final dynamic paymentMethod;
  final dynamic createdAt;
  final dynamic reservation;

  Bill({
    required this.id,
    required this.totalAmount,
    required this.paid,
    required this.billReference,
    required this.paymentMethod,
    required this.createdAt,
    required this.reservation,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      totalAmount: json['totalAmount'],
      paid: json['paid'],
      billReference: json['billReference'],
      paymentMethod: json['paymentMethod'],
      createdAt: json['createdAt'],
      reservation: json['reservation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'paid': paid,
      'billReference': billReference,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
      'reservation': reservation,
    };
  }
}
