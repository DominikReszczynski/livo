import 'package:cas_house/main_global.dart';
import 'package:cas_house/providers/dasboard_provider.dart';
import 'package:cas_house/providers/expanses_provider.dart';
import 'package:cas_house/providers/shopping_list_provider.dart';
import 'package:cas_house/providers/user_provider.dart';
import 'package:cas_house/sections/expenses/expenses_main.dart';
import 'package:cas_house/sections/dashboard/dashboard_main.dart';
import 'package:cas_house/sections/login.dart';
import 'package:cas_house/sections/shoppingList/shopping_list_main.dart';
import 'package:cas_house/sections/user/user_main.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/nav_bar/nav_bar_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ExpansesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: chosenMode,
        builder: (context, themeMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            home: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return userProvider.isLoggedIn
                    ? const HelloButton()
                    : const LoginScreen();
              },
            ),
          );
        });
  }
}

class HelloButton extends StatefulWidget {
  const HelloButton({super.key});

  @override
  _HelloButtonState createState() => _HelloButtonState();
}

class _HelloButtonState extends State<HelloButton> {
  String message = "Press the button to fetch data";

  Future<void> fetchMessage() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/hello'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          message = data['message'];
        });
      } else {
        setState(() {
          message = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // Pass chosenSection and rebuild SectionMain when it changes
          ValueListenableBuilder<MainViews>(
        valueListenable:
            currentSite, // Observing the global `currentSite` for changes.
        builder: (context, currentSiteValue, child) {
          return _buildBody(); // Dynamically build the screen based on the selected view.
        },
      ),
      bottomNavigationBar: const NavBarMain(),
    );
  }

  Widget _buildBody() {
    switch (currentSite.value) {
      case MainViews.dashboard:
        return const HomeSectionMain();
      case MainViews.expenses:
        return const ExpensesSectionMain();
      case MainViews.shoppingList:
        return const ShoppingMain();
      case MainViews.user:
        return const UserSectionMain();
      default:
        return const Center(
            child: Text('Unknown section', style: TextStyle(fontSize: 24)));
    }
  }
}
