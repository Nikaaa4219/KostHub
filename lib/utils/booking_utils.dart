import 'package:intl/intl.dart';

// == LOGIKA BISNIS & ALGORITMA ==
int inclusiveMonthsCount(DateTime a, DateTime b) {
  final start = DateTime(a.year, a.month);
  final end = DateTime(b.year, b.month);
  final yearDiff = end.year - start.year;
  final monthDiff = end.month - start.month;
  // Minimal 1 bulan
  final total = yearDiff * 12 + monthDiff + 1;
  return total < 1 ? 1 : total;
}

// == ARSITEKTUR & STRUKTUR DATA ==
class PriceBreakdown {
  final int basePrice;
  final int luxurySurcharge;
  final int guestSurcharge;
  final int fees;
  final int grandTotal;

  PriceBreakdown({
    required this.basePrice,
    required this.luxurySurcharge,
    required this.guestSurcharge,
    required this.fees,
    required this.grandTotal,
  });
}

// == LOGIKA BISNIS ==
PriceBreakdown calculatePriceBreakdown({
  required int monthlyPrice,
  required int months,
  required int adults,
  required int children,
  required String selectedRoom,
  int fees = 10000,
}) {
  final int basePrice = monthlyPrice * months;

  final String roomLower = selectedRoom.toLowerCase();
  double luxuryMultiplier = 0.0;

  if (roomLower.contains('vip') || roomLower.contains('vvip')) {
    luxuryMultiplier = 0.25; // VIP kena +25%
  } else if (roomLower.contains('view') || roomLower.contains('taman')) {
    luxuryMultiplier = 0.10; // View Taman kena +10%
  }
  final int luxurySurcharge = (basePrice * luxuryMultiplier).round();

  int billableGuests = adults + children;
  int guestSurcharge = 0;

  if (billableGuests > 2) {
    int extraCount = billableGuests - 2;
    int extraAdults = adults > 2 ? adults - 2 : 0;
    int extraChildren = extraCount - extraAdults;
    int adultCharge = (monthlyPrice * 0.10).round() * extraAdults;
    int childCharge = (monthlyPrice * 0.05).round() * extraChildren;
    guestSurcharge = (adultCharge + childCharge) * months;
  }
  final int grandTotal = basePrice + luxurySurcharge + guestSurcharge + fees;

  return PriceBreakdown(
    basePrice: basePrice,
    luxurySurcharge: luxurySurcharge,
    guestSurcharge: guestSurcharge,
    fees: fees,
    grandTotal: grandTotal,
  );
}

final _currencyFmt = NumberFormat.currency(
  locale: 'id',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatCurrency(num amount) => _currencyFmt.format(amount);
