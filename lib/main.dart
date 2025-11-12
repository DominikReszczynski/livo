import 'package:cas_house/main_global.dart';
import 'package:cas_house/providers/dasboard_provider.dart';
import 'package:cas_house/providers/payment_provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/providers/user_provider.dart';
import 'package:cas_house/sections/payment/payment_main.dart';
import 'package:cas_house/sections/properties/properties_main.dart';
import 'package:cas_house/sections/dashboard/dashboard_main.dart';
import 'package:cas_house/sections/login.dart';
import 'package:cas_house/sections/defects/defects_main.dart';
import 'package:cas_house/sections/user/user_main.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/nav_bar/nav_bar_main.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance(); // Initialize prefs

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => PropertiesProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider(prefs)),
        ChangeNotifierProvider(
            create: (_) => DefectsProvider(UserProvider(prefs))),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
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
            title: 'Livo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeMode,
            home: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return userProvider.loggedIn
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
  HelloButtonState createState() => HelloButtonState();
}

class HelloButtonState extends State<HelloButton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<MainViews>(
        valueListenable: currentSite,
        builder: (context, currentSiteValue, child) {
          return _buildBody();
        },
      ),
      bottomNavigationBar: const NavBarMain(),
    );
  }

  Widget _buildBody() {
    switch (currentSite.value) {
      case MainViews.dashboard:
        return const HomeSectionMain();
      case MainViews.properties:
        return const ExpensesSectionMain();
      case MainViews.defects:
        return const DefectsMain();
      case MainViews.user:
        return const UserSectionMain();
      case MainViews.payment:
        return const PaymentMain();
    }
  }
}
