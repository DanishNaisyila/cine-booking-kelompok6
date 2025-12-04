import 'package:intl/intl.dart';
import '../utils/constants.dart';

class CalculationServiceNadif {
  static bool validateStudentEmail(String email) {
    return email.endsWith(AppConstants.studentEmailSuffix);
  }

  static int parseSeatNumber(String seatCode) {
    try {
      return int.tryParse(seatCode) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static bool isEvenSeat(String seatCode) {
    final seatNumber = parseSeatNumber(seatCode);
    return seatNumber % 2 == 0;
  }

  static String generateQRData({
    required String bookingId,
    required String movieTitle,
    required List<String> seats,
    required int totalPrice,
    required DateTime bookingDate,
    required String movieId,
    required String userId,
  }) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return '''
🎟️ CINEBOOKING TICKET 🎟️
===============================
MOVIE: $movieTitle
SEATS: ${seats.join(', ')}
TOTAL: Rp $totalPrice
DATE: ${formatter.format(bookingDate)}
BOOKING ID: $bookingId
USER ID: ${userId.substring(0, 8)}
MOVIE ID: $movieId
===============================
⚠️ This ticket is PERMANENT
⚠️ Non-refundable & Non-transferable
===============================
SCAN FOR THEATER ENTRY
''';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static int calculateSeatPrice(String seatCode, int basePrice) {
    if (isEvenSeat(seatCode)) {
      return (basePrice * (1 - AppConstants.evenSeatDiscount)).toInt();
    }
    return basePrice;
  }

  static int calculateTitleTax(String title, int seatCount) {
    return title.length > 10 ? AppConstants.titleTax * seatCount : 0;
  }

  static int calculateTotalPrice({
    required List<String> seats,
    required String movieTitle,
    required int basePrice,
  }) {
    if (seats.isEmpty) return 0;

    int total = 0;
    for (final seat in seats) {
      total += calculateSeatPrice(seat, basePrice);
    }

    total += calculateTitleTax(movieTitle, seats.length);
    return total;
  }

  static String generatePriceBreakdown({
    required String movieTitle,
    required List<String> seats,
    required int basePrice,
  }) {
    final total = calculateTotalPrice(
      seats: seats,
      movieTitle: movieTitle,
      basePrice: basePrice,
    );

    final evenSeats = seats.where((seat) => isEvenSeat(seat)).length;
    final oddSeats = seats.length - evenSeats;
    final titleTax = calculateTitleTax(movieTitle, seats.length);
    final evenSeatDiscount = (basePrice * AppConstants.evenSeatDiscount * evenSeats).toInt();
    final hasTitleTax = movieTitle.length > 10;

return '''
=== PRICE BREAKDOWN ===
Base Price: Rp $basePrice x ${seats.length}
Even Seats (${evenSeats}): -10% each (Rp $evenSeatDiscount discount)
Odd Seats (${oddSeats}): Regular price
${hasTitleTax
    ? "Title Tax (${movieTitle.length} chars): +Rp $titleTax"
    : "Title Tax: No tax"
}

TOTAL: Rp $total
''';

  }

  static String getSeatSummary(List<String> seats) {
    if (seats.isEmpty) return 'No seats selected';
    
    final evenSeats = seats.where((seat) => isEvenSeat(seat)).toList();
    final oddSeats = seats.where((seat) => !isEvenSeat(seat)).toList();
    
    String summary = '';
    if (evenSeats.isNotEmpty) {
      summary += 'Even seats: ${evenSeats.join(', ')} (-10% each)\n';
    }
    if (oddSeats.isNotEmpty) {
      summary += 'Odd seats: ${oddSeats.join(', ')} (regular price)';
    }
    return summary.trim();
  }
}