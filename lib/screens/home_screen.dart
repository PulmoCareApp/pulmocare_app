import 'package:flutter/material.dart';
import '../widgets/medication_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy Data for medications
  final List<Map<String, dynamic>> _medications = [
    {
      'title': 'Rifampicin 600mg',
      'timeText': 'PAGI • 08:00 AM',
      'description': 'Diminum sebelum makan',
      'status': 'done',
    },
    {
      'title': 'Isoniazid 300mg',
      'timeText': 'PAGI • 08:00 AM',
      'description': 'Diminum sebelum makan',
      'status': 'todo',
    },
    {
      'title': 'Pyrazinamide 500mg',
      'timeText': 'MALAM • 08:00 PM',
      'description': 'Sesudah makan',
      'status': 'waiting',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Greeting
              const Text(
                'Selamat Pagi, Arthur!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semangat terus di perjalanan\npemulihanmu!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2E5B53),
                ),
              ),
              const SizedBox(height: 32),

              // Progress Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EED8), // Light green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progres Pengobatan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hari 122/128',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '6 Hari Tersisa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 122 / 128,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50), // Vibrant green for progress
                        ),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Medication Schedule Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jadwal Obat Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'LIHAT SEMUA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Medication List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return MedicationCard(
                    title: med['title'],
                    timeText: med['timeText'],
                    description: med['description'],
                    status: med['status'],
                    isLast: index == _medications.length - 1,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
