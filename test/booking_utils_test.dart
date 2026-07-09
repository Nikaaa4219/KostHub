import 'package:flutter_test/flutter_test.dart';
// Pastikan nama package ('flutter_application_2') sesuai dengan yang ada di pubspec.yaml Anda
import 'package:flutter_application_2/utils/booking_utils.dart';

void main() {
  test('inclusiveMonthsCount menghitung bulan secara inklusif', () {
    final a = DateTime(2023, 1, 1);
    final b = DateTime(2023, 3, 1);
    expect(inclusiveMonthsCount(a, b), 3);
  });

  test(
      'calculatePriceBreakdown: Kamar Standard, 2 Dewasa (Tanpa Biaya Tambahan)',
      () {
    final breakdown = calculatePriceBreakdown(
      monthlyPrice: 2500000,
      months: 2,
      adults: 2,
      children: 0,
      selectedRoom: 'Room A-101 (Lantai 1)', // Standard = 0%
      fees: 10000,
    );

    // Harga Dasar: 2.500.000 * 2 = 5.000.000
    expect(breakdown.basePrice, 5000000);
    // Kemewahan: 0
    expect(breakdown.luxurySurcharge, 0);
    // Tambahan Tamu: 0 (Kapasitas pas 2)
    expect(breakdown.guestSurcharge, 0);
    // Pajak/Biaya Admin: 10.000
    expect(breakdown.fees, 10000);
    // Grand Total: 5.010.000
    expect(breakdown.grandTotal, 5010000);
  });

  test(
      'calculatePriceBreakdown: Kamar VIP, 3 Dewasa (Ada Biaya Kemewahan & Tambahan Tamu)',
      () {
    final breakdown = calculatePriceBreakdown(
      monthlyPrice: 2500000,
      months: 2,
      adults: 3, // Kelebihan 1 Dewasa
      children: 0,
      selectedRoom: 'Room C-301 (Lantai 3 - VIP)', // VIP = +25%
      fees: 10000,
    );

    // Harga Dasar: 2.500.000 * 2 = 5.000.000
    expect(breakdown.basePrice, 5000000);

    // Kemewahan: 25% dari 5.000.000 = 1.250.000
    expect(breakdown.luxurySurcharge, 1250000);

    // Tambahan Tamu: 1 Dewasa (10% dari 2.500.000) * 2 Bulan = 250.000 * 2 = 500.000
    expect(breakdown.guestSurcharge, 500000);

    // Pajak: 10.000
    expect(breakdown.fees, 10000);

    // Grand Total: 5.000.000 + 1.250.000 + 500.000 + 10.000 = 6.760.000
    expect(breakdown.grandTotal, 6760000);
  });
}
