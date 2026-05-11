import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'screening_screen.dart';
import 'medication_screen.dart';
import 'education_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScreeningScreen(),
    const MedicationScreen(),
    const EducationScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF4F7F6),
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFF819A8A), // Muted green
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, Icons.home, 'HOME', 0),
            label: _selectedIndex == 0 ? '' : 'HOME',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.show_chart_outlined, Icons.show_chart, 'SCREENING', 1),
            label: _selectedIndex == 1 ? '' : 'SCREENING',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.medical_services_outlined, Icons.medical_services, 'MEDICATION', 2),
            label: _selectedIndex == 2 ? '' : 'MEDICATION',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.menu_book_outlined, Icons.menu_book, 'EDUCATION', 3),
            label: _selectedIndex == 3 ? '' : 'EDUCATION',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person_outline, Icons.person, 'PROFILE', 4),
            label: _selectedIndex == 4 ? '' : 'PROFILE',
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData unselectedIcon, IconData selectedIcon, String label, int index) {
    if (_selectedIndex == index) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selectedIcon, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Icon(unselectedIcon, color: const Color(0xFF819A8A));
  }
}
