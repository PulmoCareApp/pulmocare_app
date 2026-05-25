import 'package:flutter/material.dart';

class AddTimeScreen extends StatefulWidget {
  final String? initialTime; // format "HH:mm"
  const AddTimeScreen({Key? key, this.initialTime}) : super(key: key);

  @override
  State<AddTimeScreen> createState() => _AddTimeScreenState();
}

class _AddTimeScreenState extends State<AddTimeScreen> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();

  @override
  void initState() {
    super.initState();

    // Parse initial time if provided
    if (widget.initialTime != null && widget.initialTime!.contains(':')) {
      final parts = widget.initialTime!.split(':');
      int h = int.tryParse(parts[0]) ?? 8;
      int m = int.tryParse(parts[1]) ?? 0;
      _isAM = h < 12;
      _selectedHour = h % 12 == 0 ? 12 : h % 12;
      _selectedMinute = m;
    } else {
      _selectedHour = 8;
      _selectedMinute = 0;
      _isAM = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourController.jumpToItem(_selectedHour - 1);
      _minuteController.jumpToItem(_selectedMinute);
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  String get _displayTime {
    final hStr = _selectedHour.toString().padLeft(2, '0');
    final mStr = _selectedMinute.toString().padLeft(2, '0');
    final period = _isAM ? 'AM' : 'PM';
    return '$hStr:$mStr $period';
  }

  String get _time24h {
    int h = _selectedHour;
    if (_isAM && h == 12) h = 0;
    if (!_isAM && h != 12) h += 12;
    return '${h.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
  }

  String get _periodLabel {
    final h24 = int.parse(_time24h.split(':')[0]);
    if (h24 >= 5 && h24 < 12) return 'Pagi';
    if (h24 >= 12 && h24 < 17) return 'Siang';
    if (h24 >= 17 && h24 < 21) return 'Sore';
    return 'Malam';
  }

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
              Text(
                _displayTime,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F3D1B),
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _periodLabel,
                  style: const TextStyle(
                    color: Color(0xFF0F3D1B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Time Picker Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour Picker
                  _buildWheelPicker(
                    controller: _hourController,
                    itemCount: 12,
                    itemBuilder: (index) => (index + 1).toString().padLeft(2, '0'),
                    onChanged: (index) {
                      setState(() => _selectedHour = index + 1);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      ':',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3D1B)),
                    ),
                  ),
                  // Minute Picker
                  _buildWheelPicker(
                    controller: _minuteController,
                    itemCount: 60,
                    itemBuilder: (index) => index.toString().padLeft(2, '0'),
                    onChanged: (index) {
                      setState(() => _selectedMinute = index);
                    },
                  ),
                  const SizedBox(width: 20),

                  // AM/PM Toggle
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isAM = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: _isAM
                                ? const Color(0xFF0F3D1B)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color: _isAM ? Colors.white : Colors.black38,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isAM = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isAM
                                ? const Color(0xFF0F3D1B)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PM',
                            style: TextStyle(
                              color: !_isAM ? Colors.white : Colors.black38,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Time-of-day pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPill('Pagi', _periodLabel == 'Pagi'),
                  const SizedBox(width: 8),
                  _buildPill('Siang', _periodLabel == 'Siang'),
                  const SizedBox(width: 8),
                  _buildPill('Sore', _periodLabel == 'Sore'),
                  const SizedBox(width: 8),
                  _buildPill('Malam', _periodLabel == 'Malam'),
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
                  // Return the selected time in 24h format "HH:mm"
                  Navigator.pop(context, _time24h);
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
            const SizedBox(height: 12),
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

  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) itemBuilder,
    required void Function(int) onChanged,
  }) {
    return SizedBox(
      width: 64,
      height: 160,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 48,
        perspective: 0.003,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected =
                controller.hasClients && controller.selectedItem == index;
            return Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: isSelected ? 28 : 18,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF0F3D1B)
                      : Colors.black38,
                ),
                child: Text(itemBuilder(index)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPill(String text, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F3D1B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF0F3D1B) : Colors.black12,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
