import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/movie_model_all_azka.dart';
import '../services/firebase_service_azka.dart';
import '../services/calculation_service_nadif.dart';

class BookingControllerNadif extends ChangeNotifier {
  final FirebaseServiceAzka _firebaseService = FirebaseServiceAzka();
  final Uuid _uuid = const Uuid();

  List<String> _selectedSeats = [];
  List<BookingModelAzka> _userBookings = [];
  List<String> _bookedSeats = [];

  String? _currentUserId;
  bool _isLoading = false;
  String? _error;

  List<String> get selectedSeats => _selectedSeats;
  List<BookingModelAzka> get userBookings => _userBookings;
  List<String> get bookedSeats => _bookedSeats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSelectedSeats => _selectedSeats.isNotEmpty;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    loadUserBookings();
  }

  void resetAll() {
    _currentUserId = null;
    _selectedSeats.clear();
    _userBookings.clear();
    _bookedSeats.clear();
    _error = null;
    notifyListeners();
  }

  Future<void> loadBookedSeats(String movieId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookedSeats = await _firebaseService.getBookedSeats(movieId);
    } catch (e) {
      _error = 'Gagal memuat kursi yang sudah dipesan';
      print("LOAD BOOKED SEATS ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSeatAvailable(String seatId) => !_bookedSeats.contains(seatId);
  bool isSeatSelected(String seatId) => _selectedSeats.contains(seatId);

  void toggleSeat(String seatId) {
    if (!isSeatAvailable(seatId)) {
      _error = 'Kursi $seatId sudah dipesan';
      notifyListeners();
      return;
    }

    if (_selectedSeats.contains(seatId)) {
      _selectedSeats.remove(seatId);
    } else {
      _selectedSeats.add(seatId);
    }
    _error = null;
    notifyListeners();
  }

  void clearSelectedSeats() {
    _selectedSeats.clear();
    _error = null;
    notifyListeners();
  }

  int calculateTotalPrice(String title, int basePrice) {
    return CalculationServiceNadif.calculateTotalPrice(
      seats: _selectedSeats,
      movieTitle: title,
      basePrice: basePrice,
    );
  }

  Future<String?> createBooking({
    required String movieId,
    required String movieTitle,
    required int basePrice,
  }) async {
    if (_currentUserId == null) throw 'Silakan login terlebih dahulu';
    if (_selectedSeats.isEmpty) throw 'Pilih minimal satu kursi';

    for (final seat in _selectedSeats) {
      if (_bookedSeats.contains(seat)) {
        throw 'Kursi $seat sudah dipesan orang lain';
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final bookingId = _uuid.v4();
      final now = DateTime.now();
      final totalPrice = calculateTotalPrice(movieTitle, basePrice);

      final qrData = CalculationServiceNadif.generateQRData(
        bookingId: bookingId,
        movieTitle: movieTitle,
        seats: _selectedSeats,
        totalPrice: totalPrice,
        bookingDate: now,
        movieId: movieId,
        userId: _currentUserId!,
      );

      final booking = BookingModelAzka(
        bookingId: bookingId,
        userId: _currentUserId!,
        movieId: movieId,
        movieTitle: movieTitle,
        seats: List.from(_selectedSeats),
        totalPrice: totalPrice,
        bookingDate: now,
        qrData: qrData,
      );

      await _firebaseService.createBooking(booking);

      await Future.wait([
        loadUserBookings(),
        loadBookedSeats(movieId),
      ]);

      _selectedSeats.clear();
      notifyListeners();

      return bookingId;
      
    } catch (e) {
      if (e.toString().contains('network')) {
        _error = 'Tidak ada koneksi internet';
      } else if (e.toString().contains('seat')) {
        _error = 'Kursi sudah tidak tersedia';
      } else if (e.toString().contains('booked_seats')) {
        _error = 'Error sistem database';
      } else {
        _error = 'Gagal membuat booking';
      }
      
      notifyListeners();
      rethrow;
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserBookings() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await _firebaseService.getUserBookings(_currentUserId!);
    } catch (e) {
      _error = 'Gagal memuat riwayat booking';
      print("LOAD USER BOOKINGS ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BookingModelAzka? getBookingById(String bookingId) {
    try {
      return _userBookings.firstWhere((b) => b.bookingId == bookingId);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String getPriceBreakdown(String title, int basePrice) {
    return CalculationServiceNadif.generatePriceBreakdown(
      movieTitle: title,
      seats: _selectedSeats,
      basePrice: basePrice,
    );
  }
}