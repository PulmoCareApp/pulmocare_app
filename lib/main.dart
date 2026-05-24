import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();

  await Supabase.initialize(
    url: 'https://dkporkkeltewfvwkigep.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrcG9ya2tlbHRld2Z2d2tpZ2VwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwNDAzMzcsImV4cCI6MjA5NDYxNjMzN30.fQKc2fGeZoxhbPlyed_Bu5twahtYmekmiUcufpbzqzI',
  );

  runApp(const PulmoCareApp());
}

class PulmoCareApp extends StatefulWidget {
  const PulmoCareApp({Key? key}) : super(key: key);

  @override
  State<PulmoCareApp> createState() => _PulmoCareAppState();
}

class _PulmoCareAppState extends State<PulmoCareApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _isLoggedIn = data.session != null;
        });
      }
    });
  }

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
      home: _isLoggedIn ? const MainNavigation() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
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
