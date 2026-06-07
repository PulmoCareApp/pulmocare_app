import 'package:flutter/material.dart';

class HomeMedicationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status; // 'done', 'todo', 'waiting'
  final VoidCallback? onConfirm;

  const HomeMedicationCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Color borderCol;
    Color iconBg;
    Color iconCol;
    Widget trailingWidget;

    if (status == 'done') {
      cardBg = const Color(0xFFF9FBF9);
      borderCol = Colors.black.withOpacity(0.05);
      iconBg = Colors.white;
      iconCol = const Color(0xFF1B5E20);
      trailingWidget = const Icon(
        Icons.check_circle_outline,
        color: Color(0xFF1B5E20),
        size: 24,
      );
    } else if (status == 'todo') {
      cardBg = const Color(0xFFF1F8F3);
      borderCol = const Color(0xFFC8E6C9);
      iconBg = const Color(0xFF0F3D1B);
      iconCol = Colors.white;
      trailingWidget = ElevatedButton(
        onPressed: onConfirm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F3D1B),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Minum',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // waiting
      cardBg = const Color(0xFFF9FBF9);
      borderCol = Colors.black.withOpacity(0.05);
      iconBg = Colors.white;
      iconCol = Colors.black38;
      trailingWidget = const Icon(
        Icons.access_time,
        color: Colors.black38,
        size: 24,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1),
      ),
      child: Row(
        children: [
          // Medication Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              border: status != 'todo' ? Border.all(color: Colors.black.withOpacity(0.05)) : null,
            ),
            child: Icon(
              Icons.local_pharmacy,
              color: iconCol,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: status == 'waiting' ? Colors.black45 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          // Action / Status Indicator
          trailingWidget,
        ],
      ),
    );
  }
}
