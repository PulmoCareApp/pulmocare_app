import 'package:flutter/material.dart';
import 'profile_screen.dart';
import '../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  late TextEditingController _bioController;
  late TextEditingController _targetDaysController;
  late String _selectedGender;
  late bool _hasTreatment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _birthDateController = TextEditingController(text: widget.user.birthDate.isEmpty ? '08/14/1995' : widget.user.birthDate);
    _bioController = TextEditingController(text: widget.user.bio.isEmpty ? 'Bismillah sehat dan kaya raya di umur 20-an. Bisa financial freedom di umur 20-an kaya mark lee. HUHU PENGEN.' : widget.user.bio);
    _targetDaysController = TextEditingController(text: widget.user.medicationTargetDays == 0 ? '128' : widget.user.medicationTargetDays.toString());
    _selectedGender = widget.user.gender;
    _hasTreatment = widget.user.hasTreatment;
  }

  String get avatarPath {
    if (_selectedGender == 'Perempuan') return 'assets/images/avatar_female.png';
    if (_selectedGender == 'Laki-laki') return 'assets/images/avatar_male.png';
    return 'assets/images/avatar_default.png';
  }

  bool _isSaving = false;

  void _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      final currentProfile = await SupabaseService().getUserProfile();
      DateTime? startDate;
      if (_hasTreatment) {
        if (currentProfile != null && currentProfile['treatment_start_date'] != null) {
          try {
            startDate = DateTime.parse(currentProfile['treatment_start_date']);
          } catch (_) {
            startDate = DateTime.now();
          }
        } else {
          startDate = DateTime.now();
        }
      }

      final targetDays = _hasTreatment ? (int.tryParse(_targetDaysController.text) ?? 128) : 0;

      await SupabaseService().updateUserProfile(
        email: _emailController.text,
        name: _nameController.text,
        gender: _selectedGender,
        birthDate: _birthDateController.text,
        bio: _bioController.text,
        hasTreatment: _hasTreatment,
        medicationTargetDays: targetDays,
        treatmentStartDate: startDate,
      );

      int tDay = 0;
      if (_hasTreatment && startDate != null) {
        tDay = DateTime.now().difference(startDate).inDays;
        if (tDay < 0) tDay = 0;
      }

      final updatedUser = UserModel(
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGender,
        birthDate: _birthDateController.text,
        bio: _bioController.text,
        hasTreatment: _hasTreatment,
        treatmentDay: tDay,
        medicationTargetDays: targetDays,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // AVATAR SECTION
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.asset(
                        avatarPath,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Ubah Foto Profil',
                style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),

            // FORM FIELDS
            _buildFieldLabel('NAMA LENGKAP'),
            _buildTextField(controller: _nameController),
            const SizedBox(height: 20),

            _buildFieldLabel('EMAIL'),
            _buildTextField(controller: _emailController),
            const SizedBox(height: 20),

            _buildFieldLabel('JENIS KELAMIN'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Belum diisi', 'Laki-laki', 'Perempuan'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            _buildFieldLabel('TANGGAL LAHIR'),
            _buildTextField(controller: _birthDateController),
            const SizedBox(height: 20),

            // STATUS PENGOBATAN TBC
            _buildFieldLabel('STATUS PENGOBATAN TBC'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Sedang Menjalani Pengobatan TBC',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                subtitle: const Text(
                  'Aktifkan untuk memantau kepatuhan minum obat',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                value: _hasTreatment,
                activeColor: const Color(0xFF1B5E20),
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _hasTreatment = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            if (_hasTreatment) ...[
              _buildFieldLabel('TARGET HARI KEPATUHAN'),
              _buildTextField(
                controller: _targetDaysController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
            ],

            _buildFieldLabel('KATA SANDI'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                obscureText: true,
                readOnly: true,
                controller: TextEditingController(text: '12345678'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildFieldLabel('BIO / CATATAN KESEHATAN SINGKAT'),
            _buildTextField(
              controller: _bioController,
              maxLines: 4,
            ),
            const SizedBox(height: 40),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20), // Dark Green
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    String? initialValue,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _bioController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }
}
