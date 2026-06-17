class PaymentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceName;
  final double amount;
  final DateTime date;
  final String method; // 'M-Pesa', 'Credit Card', 'Cash'
  final String status; // 'pending', 'completed', 'failed'

  PaymentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceName,
    required this.amount,
    required this.date,
    required this.method,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'serviceName': serviceName,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'status': status,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      serviceName: map['serviceName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'].toString()),
      method: map['method'] ?? 'Cash',
      status: map['status'] ?? 'pending',
    );
  }
}
