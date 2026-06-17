class AppointmentModel {
  final String id;
  final String customerId;
  final String staffId;
  final String serviceId;
  final DateTime dateTime;
  final String status; // 'pending', 'approved', 'completed', 'cancelled'
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.staffId,
    required this.serviceId,
    required this.dateTime,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'staffId': staffId,
      'serviceId': serviceId,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      customerId: map['customerId'] ?? '',
      staffId: map['staffId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      dateTime: DateTime.parse(map['dateTime'].toString()),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
    );
  }
}
