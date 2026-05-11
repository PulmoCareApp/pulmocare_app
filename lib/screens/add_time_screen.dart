import 'package:flutter/material.dart';

class AddTimeScreen extends StatelessWidget {
  const AddTimeScreen({Key? key}) : super(key: key);

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
          'Tambah Waktu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Large Time Display
              const Text(
                '08:00',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F3D1B),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),

              // Time Picker Mockup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildScrollColumn(['06', '07', '08', '09', '10'], 2),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  _buildScrollColumn(['50', '55', '00', '05', '10'], 2),
                  const SizedBox(width: 24),
                  
                  // AM/PM Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3D1B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('AM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: const Text('PM', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Time of Day Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPill('Pagi', true),
                  const SizedBox(width: 12),
                  _buildPill('Siang', false),
                  const SizedBox(width: 12),
                  _buildPill('Malam', false),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3D1B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Simpan Waktu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollColumn(List<String> items, int selectedIndex) {
    return Column(
      children: List.generate(items.length, (index) {
        bool isSelected = index == selectedIndex;
        // Simple mock fading effect
        double opacity = 1.0;
        if (index == 0 || index == items.length - 1) opacity = 0.0; // Hide edges if we want
        else if (index == 1 || index == items.length - 2) opacity = 0.3;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            items[index],
            style: TextStyle(
              fontSize: isSelected ? 24 : 18,
              color: isSelected ? Colors.transparent : Colors.black.withOpacity(opacity),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPill(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isActive
            ? null
            : Border.all(color: Colors.black12),
        boxShadow: isActive
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
            : [],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.black87 : Colors.black54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
