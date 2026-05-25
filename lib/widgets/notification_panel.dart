import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tampilkan panel notifikasi sebagai modal bottom sheet.
/// Panggil dari mana saja dengan:
///   NotificationPanel.show(context);
class NotificationPanel {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationPanelContent(),
    );
  }
}

class _NotificationPanelContent extends StatefulWidget {
  const _NotificationPanelContent();

  @override
  State<_NotificationPanelContent> createState() =>
      _NotificationPanelContentState();
}

class _NotificationPanelContentState extends State<_NotificationPanelContent> {
  bool _isLoading = true;
  List<_NotifItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final List<_NotifItem> items = [];

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Ambil pengingat obat dari Supabase
        final data = await Supabase.instance.client
            .from('medication_reminders')
            .select()
            .eq('user_id', user.id)
            .order('time_to_take', ascending: true);

        final now = DateTime.now();
        final todayMeds = List<Map<String, dynamic>>.from(data);

        for (final med in todayMeds) {
          final timeStr = med['time_to_take'] as String? ?? '00:00';
          final parts = timeStr.split(':');
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final schedTime = DateTime(now.year, now.month, now.day, h, m);

          final name = med['medication_name'] as String? ?? 'Obat';
          final dosage = med['dosage'] as String? ?? '';
          final isPast = schedTime.isBefore(now);

          items.add(_NotifItem(
            icon: isPast ? Icons.check_circle : Icons.alarm,
            iconColor: isPast ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
            bgColor: isPast
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF3E0),
            title: isPast
                ? 'Sudah Diminum — $name'
                : 'Pengingat — $name',
            subtitle: '${_fmt12h(h, m)} • $dosage',
            time: isPast ? 'Selesai' : _relativeTime(schedTime, now),
          ));
        }
      }
    } catch (_) {}

    // Tambah notifikasi tips statis jika list kosong
    if (items.isEmpty) {
      items.add(_NotifItem(
        icon: Icons.info_outline,
        iconColor: const Color(0xFF1B5E20),
        bgColor: const Color(0xFFE8F5E9),
        title: 'Belum Ada Pengingat',
        subtitle: 'Buat pengingat obat di tab Medication untuk mendapat notifikasi.',
        time: 'Sekarang',
      ));
    }

    // Selalu tambah tips kesehatan
    items.add(_NotifItem(
      icon: Icons.tips_and_updates_outlined,
      iconColor: const Color(0xFF1565C0),
      bgColor: const Color(0xFFE3F2FD),
      title: 'Tips Kesehatan',
      subtitle: 'Jangan lupa minum air 8 gelas sehari untuk membantu pemulihan.',
      time: 'Hari ini',
    ));

    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  String _fmt12h(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  String _relativeTime(DateTime sched, DateTime now) {
    final diff = sched.difference(now);
    if (diff.inMinutes < 0) return 'Terlewat';
    if (diff.inMinutes == 0) return 'Sekarang';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lagi';
    return '${diff.inHours} jam lagi';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications,
                              color: Color(0xFF1B5E20), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notifikasi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F3D1B),
                          ),
                        ),
                      ],
                    ),
                    // Badge jumlah item
                    if (_items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_items.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF1B5E20)))
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildItem(_items[i]),
                      ),
              ),

              // Footer
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFD4EED8)),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(_NotifItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.time,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black38),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}
