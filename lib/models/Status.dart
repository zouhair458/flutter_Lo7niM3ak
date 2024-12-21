enum Status {
  PENDING,
  ACCEPTED,
  REFUSED,
  CANCELED,
  CLOSED,
}

extension StatusExtension on Status {
  String get name => toString().split('.').last;

  static Status fromString(String status) {
    return Status.values.firstWhere((e) => e.name == status);
  }
}
