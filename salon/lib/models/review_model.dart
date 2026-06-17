class ReviewModel {
  final String id;
  final String customerId;
  final String serviceId;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'serviceId': serviceId,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      customerId: map['customerId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      date: DateTime.parse(map['date'].toString()),
    );
  }
}
