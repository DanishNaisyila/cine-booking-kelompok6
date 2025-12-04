import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/booking_controller_nadif.dart';
import '../services/firebase_service_azka.dart';
import '../models/movie_model_all_azka.dart';
import '../services/calculation_service_nadif.dart';
import '../utils/constants.dart';

class ProfileScreenNadif extends StatefulWidget {
  final String? highlightBookingId;

  const ProfileScreenNadif({super.key, this.highlightBookingId});

  @override
  State<ProfileScreenNadif> createState() => _ProfileScreenNadifState();
}

class _ProfileScreenNadifState extends State<ProfileScreenNadif> {
  String? _userEmail;
  String? _username;
  bool _triedOpenHighlight = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHighlightQR();
    });
  }

  Future<void> _loadUserData() async {
    final service = FirebaseServiceAzka();
    final user = service.getCurrentUser();
    if (user != null) {
      final userData = await service.getUserData(user.uid);
      setState(() {
        _userEmail = user.email;
        _username = userData?.username ?? 'User';
      });
    }
  }

  Future<void> _logout() async {
    final firebaseService = FirebaseServiceAzka();
    final controller = Provider.of<BookingControllerNadif>(context, listen: false);
    await firebaseService.logoutUser();
    controller.resetAll();
  }

  void _maybeShowHighlightQR() {
    if (_triedOpenHighlight) return;
    _triedOpenHighlight = true;

    final highlightId = widget.highlightBookingId;
    if (highlightId == null) return;

    final controller = Provider.of<BookingControllerNadif>(context, listen: false);
    final booking = controller.getBookingById(highlightId);

    if (booking != null && booking.qrData.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showQrDialog(booking);
      });
    }
  }

  void _showQrDialog(BookingModelAzka booking) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.netflixBlack,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎟️ YOUR TICKET',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.netflixRed,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.netflixRed, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'SCAN FOR ENTRY',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: booking.qrData,
                      size: 180,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.netflixRed,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ID: ${booking.bookingId.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.netflixGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.movieTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Seats: ${booking.seats.join(', ')}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Total: Rp ${booking.totalPrice}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Date: ${CalculationServiceNadif.formatDateTime(booking.bookingDate)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Card(
      margin: const EdgeInsets.all(12),
      color: AppColors.netflixGrey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.netflixRed,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 35,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _username ?? 'Loading...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _userEmail ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Consumer<BookingControllerNadif>(
              builder: (context, controller, _) {
                final totalSpent = controller.userBookings.fold(
                  0, (sum, b) => sum + b.totalPrice
                );
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.netflixBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.netflixGrey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${controller.userBookings.length}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.netflixRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Bookings',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Rp $totalSpent',
                            style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.netflixRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Total Spent',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHistory(BookingControllerNadif controller) {
    // ✅ FIX: Only show loading if truly loading AND empty
    if (controller.isLoading && controller.userBookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.netflixRed,
          ),
        ),
      );
    }

    if (controller.userBookings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.confirmation_num_outlined,
              size: 60,
              color: AppColors.netflixLightGrey,
            ),
            const SizedBox(height: 12),
            const Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Book a movie to see your tickets here',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.netflixRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Browse Movies', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.userBookings.length,
      itemBuilder: (context, index) {
        final booking = controller.userBookings[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: AppColors.netflixGrey,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.netflixRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.netflixRed),
                      ),
                      child: Text(
                        'PERMANENT',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.netflixRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      CalculationServiceNadif.formatDate(booking.bookingDate),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  booking.movieTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.event_seat, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Seats: ${booking.seats.join(', ')}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Total: Rp ${booking.totalPrice}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showQrDialog(booking),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.netflixRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 18),
                        SizedBox(width: 6),
                        Text('View QR Code Ticket', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BookingControllerNadif>(context);

    return Scaffold(
      backgroundColor: AppColors.netflixDark,
      appBar: AppBar(
        backgroundColor: AppColors.netflixBlack,
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserCard(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📋 Booking History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            _buildBookingHistory(controller),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}