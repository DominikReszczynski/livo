import 'package:cas_house/api_service.dart';
import 'package:cas_house/models/user.dart';
import 'package:flutter/material.dart';

String apiUrl = "http://10.0.2.2:3000";
String baseUrl = 'http://localhost:3000';

String urlPrefix = ApiService.baseUrl;
// ! Chosen mode
ValueNotifier<ThemeMode> chosenMode = ValueNotifier(ThemeMode.light);

// ? Function to update chosenSection value

// Global ValueNotifier to track the currently selected view in the app.
ValueNotifier<MainViews> currentSite =
    ValueNotifier<MainViews>(MainViews.dashboard);

// Enum to define the possible views in the application.
enum MainViews { dashboard, properties, defects, payment, user }

// Define commonly used colors in the app to maintain consistency across the UI.
const Color mainDarkBlue = Color.fromARGB(255, 1, 102, 177);
const Color mainGreen = Color.fromARGB(255, 9, 222, 174);
const Color mainGrey = Color.fromARGB(255, 239, 239, 239);

// Function to convert to the correct format for parsing to double regardless of the sign
String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date);
  return "${parsedDate.day}.${parsedDate.month}.${parsedDate.year}";
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'naprawiony':
    case 'solved':
      return Colors.green;
    case 'w trakcie':
    case 'in progress':
      return Colors.orange;
    default:
      return Colors.red;
  }
}

User? loggedUser;

class LivoColors {
  static const Color background = Color(0xFFF1F1F1);
  static const Color brandGold = Color(0xFF8C6F39);
  static const Color brandBeige = Color(0xFFE7D7C6);
  static const Color text = Colors.black;
  static const Color card = Colors.white;
}
