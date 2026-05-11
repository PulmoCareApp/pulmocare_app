import 'package:flutter/material.dart';
import '../widgets/medication_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kalender Pengobatan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Calendar Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Month Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.chevron_left, color: Colors.black87),
                      const Text(
                        'Oktober 2023',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3D1B),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.black87),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Days of week
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'].map((day) {
                      return Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Dates Grid (Dummy visual representation)
                  _buildDatesRow(['28', '29', '30', '1', '2', '3', '4'],
                      statuses: [null, null, null, 'done', 'done', 'missed', 'done'], isMutedRow: true),
                  _buildDatesRow(['5', '6', '7', '8', '9', '10', '11'],
                      statuses: ['done', 'done', 'done', 'done', 'done', 'done', 'waiting'], activeIndex: 6),
                  _buildDatesRow(['12', '13', '14', '', '', '', ''],
                      statuses: ['waiting', 'waiting', 'waiting', null, null, null, null]),

                  const SizedBox(height: 24),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(const Color(0xFF1B5E20), 'Selesai'),
                      const SizedBox(width: 16),
                      _buildLegendItem(const Color(0xFFD32F2F), 'Terlewat'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.black26, 'Akan Datang'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Dummy Medication List for selected date
            MedicationCard(
              timeText: 'PAGI • 08:00 AM',
              title: 'Rifampicin 600mg',
              description: 'Diminum sebelum makan',
              status: 'done',
            ),
            MedicationCard(
              timeText: 'SIANG • 12:30 PM',
              title: 'Ethambutol 400mg',
              description: 'Membantu menghentikan pertumbuhan bakteri TBC.',
              status: 'todo',
            ),
            MedicationCard(
              timeText: 'MALAM • 08:00 PM',
              title: 'Isoniazid 300mg',
              description: null,
              status: 'waiting',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesRow(List<String> dates, {List<String?>? statuses, int activeIndex = -1, bool isMutedRow = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = dates[index];
          if (date.isEmpty) return const SizedBox(width: 32, height: 40);

          final isActive = index == activeIndex;
          final isMuted = isMutedRow && (index < 3); // Mute days from previous month
          final status = statuses?[index];

          Color dotColor = Colors.transparent;
          if (status == 'done') dotColor = const Color(0xFF1B5E20);
          if (status == 'missed') dotColor = const Color(0xFFD32F2F);
          if (status == 'waiting') dotColor = Colors.black26;

          return Container(
            width: 36,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0F3D1B) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? Colors.white
                        : (isMuted ? Colors.black26 : Colors.black87),
                  ),
                ),
                if (status != null && !isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}
