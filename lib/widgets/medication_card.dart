import 'package:flutter/material.dart';

class MedicationCard extends StatelessWidget {
  final String timeText; // e.g., "PAGI • 08:00 AM"
  final String title; // e.g., "Rifampicin 600mg"
  final String? description; // e.g., "Diminum sebelum makan"
  final String status; // 'done', 'todo', 'waiting'
  final VoidCallback? onConfirm;
  final bool isLast;

  const MedicationCard({
    Key? key,
    required this.timeText,
    required this.title,
    this.description,
    required this.status,
    this.onConfirm,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildTimelineIcon(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFC8E6C9), // Light green line
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.transparent, // No line for last item
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Card Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0), // Spacing between cards
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: status == 'todo' ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: status == 'todo'
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                  border: Border.all(
                    color: status == 'todo' ? const Color(0xFF1B5E20) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Time and Status Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: status == 'waiting'
                                ? Colors.black38
                                : const Color(0xFF1B5E20),
                          ),
                        ),
                        _buildStatusLabel(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: status == 'waiting' ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    if (description != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (status == 'done')
                            const Padding(
                              padding: EdgeInsets.only(top: 2.0, right: 6.0),
                              child: Icon(Icons.info_outline, size: 14, color: Colors.black54),
                            ),
                          Expanded(
                            child: Text(
                              description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Action Button
                    if (status == 'todo') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F3D1B), // Very dark green
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Konfirmasi Minum Obat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon() {
    if (status == 'done') {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF81C784), width: 1.5), // Light green border
        ),
        child: const Center(
          child: Icon(Icons.check, color: Color(0xFF1B5E20), size: 18),
        ),
      );
    } else if (status == 'todo') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1B5E20), width: 2), // Dark green border
        ),
        child: Center(
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 14),
          ),
        ),
      );
    } else {
      // waiting
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26, width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.access_time, color: Colors.black54, size: 16),
        ),
      );
    }
  }

  Widget _buildStatusLabel() {
    if (status == 'done') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFC8E6C9), // Light green
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'SUDAH\nDIMINUM',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
            height: 1.2,
          ),
        ),
      );
    } else if (status == 'todo') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F3D1B), // Very dark green
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'BELUM',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      // waiting
      return const Text(
        'TERJADWAL',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black45,
        ),
      );
    }
  }
}
