// Auto-generated per user prompt — manual review required
import 'package:intl/intl.dart';

class BookingRecord {
  final String id;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
  final int adults;
  final int children;
  final int infants;
  final int total; // in IDR
  final String invoiceId;
  final String paymentMethod;
  final DateTime timestamp;

  BookingRecord({
    required this.id,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.adults,
    required this.children,
    required this.infants,
    required this.total,
    required this.invoiceId,
    required this.paymentMethod,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'adults': adults,
    'children': children,
    'infants': infants,
    'total': total,
    'invoiceId': invoiceId,
    'paymentMethod': paymentMethod,
    'timestamp': timestamp.toIso8601String(),
  };

  factory BookingRecord.fromJson(Map<String, dynamic> j) => BookingRecord(
    id: j['id'] as String,
    roomId: j['roomId'] as String,
    startDate: DateTime.parse(j['startDate'] as String),
    endDate: DateTime.parse(j['endDate'] as String),
    adults: j['adults'] as int,
    children: j['children'] as int,
    infants: j['infants'] as int,
    total: j['total'] as int,
    invoiceId: j['invoiceId'] as String,
    paymentMethod: j['paymentMethod'] as String,
    timestamp: DateTime.parse(j['timestamp'] as String),
  );
}

final _currencyFmt = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatCurrency(int amount) => _currencyFmt.format(amount);

String generateInvoiceId() => DateTime.now().millisecondsSinceEpoch.toString();

const kHistoryKey = 'booking_history';
const kNotificationsKey = 'notifications';
