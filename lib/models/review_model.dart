class Review {
  final int id;
  final int note;
  final String message;
  final String postedBy;

  Review({
    required this.id,
    required this.note,
    required this.message,
    required this.postedBy,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      note: json['note'] ?? 0,
      message: json['message'] ?? '',
      postedBy: json['user'] != null
          ? "${json['user']['firstName'] ?? 'Unknown'} ${json['user']['name'] ?? ''}"
          : 'Unknown User',
    );
  }
}
