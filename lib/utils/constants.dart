import 'package:flutter/material.dart';

class AppConstants {
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String bookingsCollection = 'bookings';
  
  static const int totalSeats = 48;
  static const int seatsPerRow = 8;
  
  static const int basePrice = 50000;
  static const int titleTax = 2500;
  static const double evenSeatDiscount = 0.1;
  
  static const String studentEmailSuffix = '@student.univ.ac.id';
}

class AppColors {
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixDark = Color(0xFF141414);
  static const Color netflixBlack = Color(0xFF000000);
  static const Color netflixGrey = Color(0xFF2D2D2D);
  static const Color netflixLightGrey = Color(0xFF8C8C8C);
  
  static const Color seatAvailable = Color(0xFF404040);
  static const Color seatSelected = Color(0xFF2196F3);
  static const Color seatSold = Color(0xFFF44336);
  
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
}

class AppTextStyles {
  static const TextStyle netflixTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: -0.5,
  );
  
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle movieTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.white,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.netflixLightGrey,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle priceText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.netflixRed,
  );
  
  static const TextStyle seatNumber = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}