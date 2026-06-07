import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/medication_card.dart';
import '../widgets/notification_panel.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import 'add_time_screen.dart';
import 'select_days_screen.dart';

class MedicationScreen extends StatefulWidget {
  final bool isActive;
  const MedicationScreen({Key? key, this.isActive = false}) : super(key: key);

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  String _dosageUnit = 'mg';
  List<String> _times = [];
  List<String> _selectedDays = [];
  bool _isEveryDay = true;
  bool _isLoading = false;
  bool _isJadwalHariIni = true;
  int _medicationTargetDays = 0;

  // Reminder templates stored in this screen
  final List<Map<String, dynamic>> _reminderTemplates = [];
  final Set<String> _confirmedScheduleKeys = {};

  // Real-time calendar state
  late DateTime _today;
  late DateTime _selectedDate;
  late DateTime _calendarWeekStart;

  static const List<String> _dayNames = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
  static const List<String> _dayNamesFull = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  List<Map<String, dynamic>> _remindersFromDb = [];
  List<Map<String, dynamic>> _logsFromDb = [];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today;
    // Week starts on Monday
    final weekday = _today.weekday; // 1=Mon .. 7=Sun
    _calendarWeekStart = _today.subtract(Duration(days: weekday - 1));
    _loadMedicationTarget();
    _loadSchedulesAndLogs();
  }

  @override
  void didUpdateWidget(covariant MedicationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadMedicationTarget();
      _loadSchedulesAndLogs();
    }
  }

  Future<void> _loadMedicationTarget() async {
    try {
      final profile = await SupabaseService().getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _medicationTargetDays = profile['medication_target_days'] ?? 0;
        });
      }
    } catch (e) {
      print('DEBUG [MedicationScreen]: error in _loadMedicationTarget = $e');
    }
  }

  Future<void> _loadSchedulesAndLogs() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch all reminders
        final remData = await Supabase.instance.client
            .from('medication_reminders')
            .select()
            .eq('user_id', user.id);
        
        // Fetch logs for the selected date
        final logsData = await SupabaseService().getMedicationLogsForDate(_selectedDate);

        if (mounted) {
          setState(() {
            _remindersFromDb = List<Map<String, dynamic>>.from(remData);
            _logsFromDb = List<Map<String, dynamic>>.from(logsData);
            
            // Reconstruct _reminderTemplates from db reminders
            _reminderTemplates.clear();
            for (var reminder in _remindersFromDb) {
              final String fullDosage = reminder['dosage'] as String? ?? '';
              final parts = fullDosage.split(' • ');
              final String dosage = parts.isNotEmpty ? parts[0] : '';
              final String? notes = parts.length > 1 ? parts[1] : null;
              final timeRaw = reminder['time_to_take'] as String? ?? '00:00:00';
              final time = timeRaw.substring(0, 5); // HH:MM

              _reminderTemplates.add({
                'id': reminder['id'],
                'reminderIds': [reminder['id']],
                'name': reminder['medication_name'],
                'dosage': dosage,
                'notes': notes,
                'times': [time],
                'everyDay': true,
                'selectedDays': null,
              });
            }

            // Sync confirmed schedule keys from db logs
            _confirmedScheduleKeys.clear();
            for (var log in _logsFromDb) {
              final logReminderId = log['reminder_id']; // bigint
              if (logReminderId != null) {
                // Find matching reminder in _remindersFromDb by hashing its UUID
                for (var reminder in _remindersFromDb) {
                  final String reminderUuid = reminder['id'];
                  if (SupabaseService().uuidToBigInt(reminderUuid) == logReminderId) {
                    final timeRaw = reminder['time_to_take'] as String? ?? '00:00:00';
                    final time = timeRaw.substring(0, 5);
                    final scheduleKey = '${reminder['id']}_${time}_${_selectedDate.toIso8601String().split('T').first}';
                    _confirmedScheduleKeys.add(scheduleKey);
                  }
                }
              }
            }
          });
        }
      }
    } catch (e) {
      print('DEBUG [MedicationScreen]: error in _loadSchedulesAndLogs = $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- Time helpers ---
  String _formatTime12h(String time24) {
    final parts = time24.split(':');
    if (parts.length != 2) return time24;
    int h = int.tryParse(parts[0]) ?? 0;
    int m = int.tryParse(parts[1]) ?? 0;
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }

  String _periodLabel(String time24) {
    final parts = time24.split(':');
    int h = int.tryParse(parts[0]) ?? 0;
    if (h >= 5 && h < 12) return 'PAGI';
    if (h >= 12 && h < 17) return 'SIANG';
    if (h >= 17 && h < 21) return 'SORE';
    return 'MALAM';
  }

  String _dayNameFull(DateTime date) => _dayNamesFull[date.weekday - 1];

  bool _hasReminderOnDate(DateTime date) {
    if (_reminderTemplates.isEmpty) return false;
    return _reminderTemplates.any((template) {
      if (template['everyDay'] == true) return true;
      final selectedDays = template['selectedDays'] as List<String>?;
      if (selectedDays == null) return false;
      return selectedDays.contains(_dayNameFull(date));
    });
  }

  List<Map<String, dynamic>> _scheduleForDate(DateTime date) {
    final schedule = <Map<String, dynamic>>[];
    for (final template in _reminderTemplates) {
      final repeat = template['everyDay'] == true ||
          (template['selectedDays'] as List<String>?)?.contains(_dayNameFull(date)) == true;
      if (!repeat) continue;

      final times = List<String>.from(template['times'] ?? []);
      final reminderIds = List<dynamic>.from(template['reminderIds'] ?? []);
      for (var index = 0; index < times.length; index++) {
        final time = times[index];
        final scheduleKey = '${template['id']}_${time}_${date.toIso8601String().split('T').first}';
        final reminderId = reminderIds.length > index ? reminderIds[index] : null;
        schedule.add({
          'scheduleKey': scheduleKey,
          'templateId': template['id'],
          'reminderId': reminderId,
          'timeText': '${_periodLabel(time)} • ${_formatTime12h(time)}',
          'title': '${template['name']} ${template['dosage']}',
          'description': template['notes'],
          'status': _confirmedScheduleKeys.contains(scheduleKey) ? 'done' : 'todo',
          'date': date,
        });
      }
    }
    schedule.sort((a, b) => (a['timeText'] as String).compareTo(b['timeText'] as String));
    return schedule;
  }

  // --- Add / Remove time slots ---
  Future<void> _addTime() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddTimeScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        if (!_times.contains(result)) {
          _times.add(result);
          _times.sort();
        }
      });
    }
  }

  Future<void> _editTime(int index) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => AddTimeScreen(initialTime: _times[index])),
    );
    if (result != null && mounted) {
      setState(() {
        _times[index] = result;
        _times.sort();
      });
    }
  }

  void _removeTime(int index) {
    setState(() => _times.removeAt(index));
  }

  // --- Select days ---
  Future<void> _openSelectDays() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              SelectDaysScreen(initialSelectedDays: _selectedDays)),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedDays = result;
        _isEveryDay = false;
      });
    }
  }

  // --- Save reminder ---
  void _saveReminder() async {
    if (_nameController.text.trim().isEmpty ||
        _dosageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nama dan Dosis tidak boleh kosong'),
          backgroundColor: Colors.red));
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tambahkan minimal satu waktu minum obat'),
          backgroundColor: Colors.orange));
      return;
    }
    if (!_isEveryDay && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pilih minimal satu hari'),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<dynamic> createdReminderIds = [];
      final notesVal = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;
      for (String time in _times) {
        final inserted = await SupabaseService().saveMedicationReminder(
          name: _nameController.text.trim(),
          dosage: '${_dosageController.text.trim()} $_dosageUnit',
          time: time,
          notes: notesVal,
        );
        final reminderId = inserted != null ? inserted['id'] : null;
        createdReminderIds.add(reminderId);

        final parts = time.split(':');
        if (parts.length == 2) {
          await NotificationService().scheduleDailyReminder(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: 'Waktunya Minum Obat!',
            body: 'Jangan lupa minum ${_nameController.text.trim()}',
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }

      if (mounted) {
        final name = _nameController.text.trim();
        final dosage = '${_dosageController.text.trim()} $_dosageUnit';
        final notes = notesVal;
        final newTemplate = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'reminderIds': List<dynamic>.from(createdReminderIds),
          'name': name,
          'dosage': dosage,
          'notes': notes,
          'times': List<String>.from(_times),
          'everyDay': _isEveryDay,
          'selectedDays': _isEveryDay ? null : List<String>.from(_selectedDays),
        };

        setState(() {
          _reminderTemplates.add(newTemplate);
          _reminderTemplates.sort((a, b) =>
              (a['name'] as String).compareTo(b['name'] as String));
          _nameController.clear();
          _dosageController.clear();
          _notesController.clear();
          _times = [];
          _selectedDays = [];
          _isEveryDay = true;
          _isJadwalHariIni = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pengingat berhasil disimpan!'),
          backgroundColor: Color(0xFF1B5E20),
        ));

        _loadSchedulesAndLogs();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmMedication(String scheduleKey) {
    if (_confirmedScheduleKeys.contains(scheduleKey)) return;

    _confirmedScheduleKeys.add(scheduleKey);
    setState(() {});

    final scheduleItems = _scheduleForDate(_selectedDate);
    final scheduleItem = scheduleItems.firstWhere(
      (item) => item['scheduleKey'] == scheduleKey,
      orElse: () => <String, dynamic>{},
    );
    final reminderId = scheduleItem.isNotEmpty ? scheduleItem['reminderId'] as String? : null;

    SupabaseService().logMedicationTaken(reminderId: reminderId).then((_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Status obat berhasil diperbarui!'),
        backgroundColor: Color(0xFF1B5E20),
        duration: Duration(seconds: 2),
      ));
      _loadSchedulesAndLogs();
    }).catchError((e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan log: $e')));
    });
  }

  // --- Calendar week navigation ---
  void _previousWeek() {
    setState(() => _calendarWeekStart =
        _calendarWeekStart.subtract(const Duration(days: 7)));
  }

  void _nextWeek() {
    setState(
        () => _calendarWeekStart = _calendarWeekStart.add(const Duration(days: 7)));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: const [
            Icon(Icons.medication, color: Colors.white),
            SizedBox(width: 12),
            Text('Reminder Obat',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => NotificationPanel.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle tabs
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD4EED8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  _buildTab('Jadwal Hari\nIni', true),
                  _buildTab('Buat\nPengingat', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Medication target display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Kepatuhan', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text('$_medicationTargetDays hari', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController(text: _medicationTargetDays.toString());
                        return AlertDialog(
                          title: const Text('Set Target Hari Kepatuhan'),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Masukkan jumlah hari'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                            ElevatedButton(
                              onPressed: () {
                                final v = int.tryParse(controller.text) ?? 0;
                                Navigator.pop(context, v);
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        );
                      },
                    );

                    if (result != null) {
                      try {
                        await SupabaseService().updateMedicationTarget(result);
                        if (mounted) setState(() => _medicationTargetDays = result);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Target berhasil disimpan'), backgroundColor: Color(0xFF1B5E20)));
                      } catch (e) {
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan target: $e')));
                      }
                    }
                  },
                  icon: const Icon(Icons.edit, color: Color(0xFF1B5E20)),
                  label: const Text('Ubah', style: TextStyle(color: Color(0xFF1B5E20))),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isJadwalHariIni) ..._buildScheduleTab()
            else ..._buildReminderTab(),
          ],
        ),
      ),
    );
  }

  // ======================== TAB WIDGETS ========================

  Widget _buildTab(String label, bool isSchedule) {
    final isActive = isSchedule == _isJadwalHariIni;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isJadwalHariIni = isSchedule),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1B5E20) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ======================== SCHEDULE TAB ========================

  List<Widget> _buildScheduleTab() {
    final monthYear =
        '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.year}';

    // Items for the selected date
    final scheduleItems = _scheduleForDate(_selectedDate);

    return [
      // Month header + full calendar link
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthYear,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/calendar'),
            child: Row(children: const [
              Text('Kalender ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20))),
              Icon(Icons.calendar_today, size: 14, color: Color(0xFF1B5E20)),
            ]),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // Week navigation arrows
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF1B5E20)),
            onPressed: _previousWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF1B5E20)),
            onPressed: _nextWeek,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),

      // 7-day strip
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final date = _calendarWeekStart.add(Duration(days: i));
          final isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
          final isToday = date.year == _today.year &&
              date.month == _today.month &&
              date.day == _today.day;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _loadSchedulesAndLogs();
            },
            child: _buildDateItem(
              _dayNames[i],
              date.day.toString(),
              isSelected,
              isToday,
              _hasReminderOnDate(date),
            ),
          );
        }),
      ),
      const SizedBox(height: 24),

      // Medication list or empty state
      if (scheduleItems.isEmpty) ...[
        _buildEmptyState(),
      ] else ...[
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scheduleItems.length,
          itemBuilder: (context, index) {
            final med = scheduleItems[index];
            return MedicationCard(
              timeText: med['timeText'],
              title: med['title'],
              description: med['description'],
              status: med['status'],
              isLast: index == scheduleItems.length - 1,
              onConfirm: med['status'] == 'todo'
                  ? () => _confirmMedication(med['scheduleKey'])
                  : null,
            );
          },
        ),
      ],
    ];
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 48, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Jadwal Obat',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3D1B)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat pengingat obat terlebih dahulu\nuntuk melihat jadwal harian Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isJadwalHariIni = false),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Pengingat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3D1B),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
      String day, String date, bool isSelected, bool isToday, bool hasReminder) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF0F3D1B) : const Color(0xFF819A8A),
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0F3D1B) : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF1B5E20), width: 1.5)
                    : null,
              ),
              child: Center(
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            if (hasReminder)
              Positioned(
                bottom: 4,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ======================== REMINDER FORM TAB ========================

  List<Widget> _buildReminderTab() {
    return [
      // Nama Obat
      _label('Nama Obat'),
      const SizedBox(height: 8),
      _textField(_nameController, 'Contoh: Paracetamol'),
      const SizedBox(height: 16),

      // Dosis
      _label('Dosis'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _textField(_dosageController, '0',
                keyboardType: TextInputType.number),
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
                  value: _dosageUnit,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Colors.black54),
                  items: <String>['mg', 'ml', 'tablet'].map((v) {
                    return DropdownMenuItem<String>(
                        value: v,
                        child: Text(v,
                            style: const TextStyle(color: Colors.black87)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _dosageUnit = val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Frekuensi
      _label('Frekuensi'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => setState(() => _isEveryDay = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEveryDay
                    ? const Color(0xFF0F3D1B)
                    : const Color(0xFFC8E6C9),
                foregroundColor:
                    _isEveryDay ? Colors.white : const Color(0xFF1B5E20),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Setiap Hari'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _openSelectDays,
              style: ElevatedButton.styleFrom(
                backgroundColor: !_isEveryDay
                    ? const Color(0xFF0F3D1B)
                    : const Color(0xFFC8E6C9),
                foregroundColor:
                    !_isEveryDay ? Colors.white : const Color(0xFF1B5E20),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(!_isEveryDay && _selectedDays.isNotEmpty
                  ? '${_selectedDays.length} Hari'
                  : 'Pilih Hari'),
            ),
          ),
        ],
      ),
      if (!_isEveryDay && _selectedDays.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _selectedDays
              .map((d) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8E6C9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(d,
                        style: const TextStyle(
                            color: Color(0xFF0F3D1B),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ))
              .toList(),
        ),
      ],
      const SizedBox(height: 24),

      // Waktu Minum Obat
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
                      color: Color(0xFF0F3D1B)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time slots
            if (_times.isEmpty)
              const Text(
                'Belum ada waktu ditambahkan.',
                style: TextStyle(color: Colors.black38, fontSize: 13),
              ),
            ...List.generate(_times.length, (i) => _buildTimeItem(i)),

            const SizedBox(height: 16),
            // Tambah Waktu Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addTime,
                icon: const Icon(Icons.add_circle,
                    color: Color(0xFF0F3D1B), size: 18),
                label: const Text(
                  'Tambah Waktu',
                  style: TextStyle(
                      color: Color(0xFF0F3D1B),
                      fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      // Catatan
      const Text('Catatan (Opsional)',
          style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 8),
      TextField(
        controller: _notesController,
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

      // Simpan
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3D1B),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Simpan Pengingat',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildTimeItem(int index) {
    final time = _times[index];
    final label = '${_periodLabel(time)} • ${_formatTime12h(time)}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _editTime(index),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Color(0xFF1B5E20), size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeTime(index),
            child: const Icon(Icons.remove_circle,
                color: Color(0xFFD32F2F)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
      );

  Widget _textField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
