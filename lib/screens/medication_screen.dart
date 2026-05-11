import 'package:flutter/material.dart';
import '../widgets/medication_card.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({Key? key}) : super(key: key);

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  // Dummy Data for medications local state
  final List<Map<String, dynamic>> _medications = [
    {
      'id': 1,
      'timeText': 'PAGI • 08:00 AM',
      'title': 'Rifampicin 600mg',
      'description': 'Diminum sebelum makan',
      'status': 'done', // 'done', 'todo', 'waiting'
    },
    {
      'id': 2,
      'timeText': 'SIANG • 12:30 PM',
      'title': 'Ethambutol 400mg',
      'description': 'Membantu menghentikan pertumbuhan bakteri TBC.',
      'status': 'todo',
    },
    {
      'id': 3,
      'timeText': 'MALAM • 08:00 PM',
      'title': 'Isoniazid 300mg',
      'description': null,
      'status': 'waiting',
    },
  ];

  bool _isJadwalHariIni = true;

  void _confirmMedication(int id) {
    setState(() {
      final index = _medications.indexWhere((med) => med['id'] == id);
      if (index != -1) {
        _medications[index]['status'] = 'done';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status obat berhasil diperbarui!'),
        backgroundColor: Color(0xFF1B5E20),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false, // In bottom nav, usually no back button
        title: Row(
          children: const [
            Icon(Icons.arrow_back, color: Colors.white), // Visual match to design
            SizedBox(width: 16),
            Text(
              'Reminder Obat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Toggle
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD4EED8), // Light green background
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isJadwalHariIni = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isJadwalHariIni
                              ? const Color(0xFF1B5E20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Jadwal Hari\nIni',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isJadwalHariIni
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isJadwalHariIni = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isJadwalHariIni
                              ? const Color(0xFF1B5E20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Buat\nPengingat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isJadwalHariIni
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isJadwalHariIni) ...[
              // Calendar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Agustus 2024',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/calendar');
                    },
                    child: Row(
                      children: const [
                        Text(
                          'Kalender ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        Icon(Icons.calendar_today, size: 14, color: Color(0xFF1B5E20)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateItem('SEN', '12', false),
                  _buildDateItem('SEL', '13', false),
                  _buildDateItem('RAB', '14', true),
                  _buildDateItem('KAM', '15', false),
                  _buildDateItem('JUM', '16', false),
                ],
              ),
              const SizedBox(height: 32),

              // Medication List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return MedicationCard(
                    timeText: med['timeText'],
                    title: med['title'],
                    description: med['description'],
                    status: med['status'],
                    isLast: index == _medications.length - 1,
                    onConfirm: med['status'] == 'todo'
                        ? () => _confirmMedication(med['id'])
                        : null,
                  );
                },
              ),
            ] else ...[
              // "Buat Pengingat" tab
              const Text(
                'Nama Obat',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Contoh: Paracetamol',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Dosis',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(color: Colors.black38),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: 'mg',
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          items: <String>['mg', 'ml', 'tablet'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (_) {},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Frekuensi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3D1B), // Dark active
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Setiap Hari'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/select_days');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC8E6C9), // Light inactive
                        foregroundColor: const Color(0xFF1B5E20),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Pilih Hari'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Waktu Minum Obat Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 18, color: Color(0xFF0F3D1B)),
                        SizedBox(width: 8),
                        Text(
                          'Waktu Minum Obat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3D1B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTimeItem('08:00'),
                    const SizedBox(height: 12),
                    _buildTimeItem('12:30'),
                    const SizedBox(height: 16),
                    // Tambah Waktu Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_time');
                        },
                        icon: const Icon(Icons.add_circle, color: Color(0xFF0F3D1B), size: 18),
                        label: const Text(
                          'Tambah Waktu',
                          style: TextStyle(
                            color: Color(0xFF0F3D1B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.black26, style: BorderStyle.solid), // Flutter doesn't have dashed border built-in easily for buttons
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Catatan (Opsional)',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: Sesudah Makan',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: const Color(0xFFF9FBF9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3D1B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Simpan Pengingat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(String day, String date, bool isActive) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : const Color(0xFF819A8A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0F3D1B) : Colors.transparent, // Dark green for active
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: Color(0xFF1B5E20), size: 20),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Icon(Icons.remove_circle, color: Color(0xFFD32F2F)),
        ],
      ),
    );
  }
}
