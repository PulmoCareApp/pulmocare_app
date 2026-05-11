import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/screening_screen.dart';
import 'screens/result_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/calendar_screen.dart';
import 'screens/add_time_screen.dart';
import 'screens/select_days_screen.dart';
import 'screens/terms_screen.dart';

void main() {
  runApp(const PulmoCareApp());
}

class PulmoCareApp extends StatelessWidget {
  const PulmoCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Updated background color
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainNavigation(),
        '/home': (context) => const HomeScreen(),
        '/screening': (context) => const ScreeningScreen(),
        '/result': (context) => const ResultScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/add_time': (context) => const AddTimeScreen(),
        '/select_days': (context) => const SelectDaysScreen(),
        '/terms': (context) => const TermsScreen(),
      },
    );
  }
}
