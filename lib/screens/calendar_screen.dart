import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _today;
  late DateTime _displayMonth; // month currently shown
  late DateTime _selectedDate;

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _displayMonth = DateTime(_today.year, _today.month, 1);
    _selectedDate = _today;
  }

  void _prevMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  /// Returns all day cells for the current display month (padded from Mon).
  List<DateTime?> _getDayCells() {
    final firstDay = _displayMonth; // always day 1
    // weekday: 1=Mon..7=Sun → we want Mon as first column (index 0)
    final startPad = firstDay.weekday - 1; // days from previous month
    final daysInMonth =
        DateTime(_displayMonth.year, _displayMonth.month + 1, 0).day;
    final cells = <DateTime?>[];
    for (int i = 0; i < startPad; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_displayMonth.year, _displayMonth.month, d));
    }
    return cells;
  }

  bool _isToday(DateTime d) =>
      d.year == _today.year && d.month == _today.month && d.day == _today.day;

  bool _isSelected(DateTime d) =>
      d.year == _selectedDate.year &&
      d.month == _selectedDate.month &&
      d.day == _selectedDate.day;

  bool _isPast(DateTime d) =>
      d.isBefore(DateTime(_today.year, _today.month, _today.day));

  @override
  Widget build(BuildContext context) {
    final cells = _getDayCells();
    final rows = (cells.length / 7).ceil();

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
                  // Month navigation header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.black87),
                        onPressed: _prevMonth,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        '${_monthNames[_displayMonth.month - 1]} ${_displayMonth.year}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3D1B),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.black87),
                        onPressed: _nextMonth,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Day-of-week header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                            .map((d) => SizedBox(
                                  width: 36,
                                  child: Text(
                                    d,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))
                            .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Calendar grid
                  ...List.generate(rows, (row) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (col) {
                          final idx = row * 7 + col;
                          if (idx >= cells.length || cells[idx] == null) {
                            return const SizedBox(width: 36, height: 44);
                          }
                          final date = cells[idx]!;
                          final isSelected = _isSelected(date);
                          final isToday = _isToday(date);
                          final isPast = _isPast(date);

                          // Determine dot color
                          Color? dotColor;
                          if (isPast && !isToday) {
                            dotColor = const Color(0xFF1B5E20); // done (past days)
                          } else if (isToday) {
                            dotColor = const Color(0xFF1B5E20); // today
                          } else {
                            dotColor = Colors.black26; // future = upcoming
                          }

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDate = date),
                            child: Container(
                              width: 36,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0F3D1B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: const Color(0xFF1B5E20),
                                        width: 1.5)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : dotColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                          const Color(0xFF1B5E20), 'Selesai'),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                          const Color(0xFFD32F2F), 'Terlewat'),
                      const SizedBox(width: 16),
                      _buildLegendItem(Colors.black26, 'Akan Datang'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selected date label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isToday(_selectedDate)
                    ? 'Jadwal Hari Ini'
                    : 'Jadwal ${_selectedDate.day} '
                        '${_monthNames[_selectedDate.month - 1]} '
                        '${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F3D1B),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Empty state when no reminders
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.event_note_outlined,
                      size: 48, color: Color(0xFF1B5E20)),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada jadwal obat',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F3D1B)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan pengingat obat untuk\nmelihat jadwal pada kalender ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
