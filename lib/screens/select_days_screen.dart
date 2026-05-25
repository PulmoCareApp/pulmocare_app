import 'package:flutter/material.dart';

class SelectDaysScreen extends StatefulWidget {
  final List<String>? initialSelectedDays;
  const SelectDaysScreen({Key? key, this.initialSelectedDays}) : super(key: key);

  @override
  State<SelectDaysScreen> createState() => _SelectDaysScreenState();
}

class _SelectDaysScreenState extends State<SelectDaysScreen> {
  bool _selectAll = false;

  late final Map<String, bool> _days;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSelectedDays ?? [];
    _days = {
      'Senin': initial.contains('Senin'),
      'Selasa': initial.contains('Selasa'),
      'Rabu': initial.contains('Rabu'),
      'Kamis': initial.contains('Kamis'),
      'Jumat': initial.contains('Jumat'),
      'Sabtu': initial.contains('Sabtu'),
      'Minggu': initial.contains('Minggu'),
    };
    _selectAll = _days.values.every((v) => v);
  }

  void _toggleAll(bool value) {
    setState(() {
      _selectAll = value;
      _days.forEach((key, _) {
        _days[key] = value;
      });
    });
  }

  void _toggleDay(String day) {
    setState(() {
      _days[day] = !_days[day]!;
      _selectAll = _days.values.every((v) => v);
    });
  }

  List<String> get _selectedDays =>
      _days.entries.where((e) => e.value).map((e) => e.key).toList();

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
          'Pilih Hari',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rutinitas Pengobatan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3D1B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih hari untuk mengatur jadwal pengingat PulmoCare Anda. Kami akan memastikan Anda tidak melewatkan dosis.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Pilih Semua Hari
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC8E6C9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.done_all,
                            color: Color(0xFF1B5E20), size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Pilih Semua Hari',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3D1B),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _selectAll,
                    onChanged: _toggleAll,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF1B5E20),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.black12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Days List
            ..._days.keys.map((day) {
              final isSelected = _days[day]!;
              return GestureDetector(
                onTap: () => _toggleDay(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFC8E6C9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? const Color(0xFF0F3D1B)
                            : Colors.black26,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Return selected days to the caller
              Navigator.pop(context, _selectedDays);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3D1B),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              _selectedDays.isEmpty
                  ? 'Simpan Pilihan'
                  : 'Simpan (${_selectedDays.length} hari)',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
