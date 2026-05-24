import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'edit_profile_screen.dart';

class UserModel {
  String name;
  String email;
  String gender;
  String birthDate;
  String bio;
  bool hasTreatment;
  int treatmentDay;

  UserModel({
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.bio,
    required this.hasTreatment,
    required this.treatmentDay,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userAuth = Supabase.instance.client.auth.currentUser;
      final profileData = await SupabaseService().getUserProfile();
      
      if (userAuth != null && mounted) {
        setState(() {
          int tDay = 0;
          if (profileData?['has_treatment'] == true && profileData?['treatment_start_date'] != null) {
            final startDate = DateTime.parse(profileData!['treatment_start_date']);
            tDay = DateTime.now().difference(startDate).inDays;
          }

          _user = UserModel(
            name: profileData?['full_name'] ?? 'User',
            email: userAuth.email ?? '',
            gender: profileData?['gender'] ?? 'Belum diisi',
            birthDate: profileData?['birth_date'] ?? '',
            bio: profileData?['bio'] ?? '',
            hasTreatment: profileData?['has_treatment'] ?? false,
            treatmentDay: tDay,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat profil: $e')));
      }
    }
  }
  bool _reminderObat = true;
  bool _notifEdukasi = true;
  bool _laporanMingguan = false;

  String get avatarPath {
    if (_user?.gender == 'Perempuan') return 'assets/avatar_female.png';
    if (_user?.gender == 'Laki-laki') return 'assets/avatar_male.png';
    return 'assets/pulmocarelogo.jpeg';
  }

  void _navigateToEditProfile() async {
    if (_user == null) return;
    final updatedUser = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _user!),
      ),
    );

    if (updatedUser != null && updatedUser is UserModel) {
      setState(() {
        _user = updatedUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20))),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat profil.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 24, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20), // Dark green
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
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
                      const SizedBox(height: 16),
                      Text(
                        _user!.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_user!.hasTreatment) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA5D6A7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pasien TBC - Hari ke-${_user!.treatmentDay}',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // STATS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('68%', 'PROGRES'),
                          Container(width: 1, height: 40, color: Colors.white30),
                          _buildStatItem('98%', 'KEPATUHAN'),
                          Container(width: 1, height: 40, color: Colors.white30),
                          _buildStatItem('58', 'HARI LAGI'),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      tooltip: 'Edit Profil',
                      onPressed: _navigateToEditProfile,
                    ),
                  ),
                ],
              ),
            ),
            
            // BODY SECTION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('INFO AKUN'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildInfoItem(Icons.person_outline, 'NAMA', _user!.name),
                        const Divider(height: 1, indent: 64, endIndent: 20),
                        _buildInfoItem(Icons.email_outlined, 'EMAIL', _user!.email),
                        const Divider(height: 1, indent: 64, endIndent: 20),
                        _buildInfoItem(Icons.wc_outlined, 'GENDER', _user!.gender),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('NOTIFIKASI'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchItem(Icons.medication_outlined, 'Reminder Obat', _reminderObat, (val) => setState(() => _reminderObat = val)),
                        const Divider(height: 1, indent: 64, endIndent: 20),
                        _buildSwitchItem(Icons.school_outlined, 'Notif Edukasi', _notifEdukasi, (val) => setState(() => _notifEdukasi = val)),
                        const Divider(height: 1, indent: 64, endIndent: 20),
                        _buildSwitchItem(Icons.bar_chart_outlined, 'Laporan Mingguan', _laporanMingguan, (val) => setState(() => _laporanMingguan = val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('PRIVASI & KEAMANAN'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildActionItem(Icons.person_outline, 'Edit Profile', onTap: _navigateToEditProfile),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('LAINNYA'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildActionItem(
                      Icons.description_outlined, 
                      'Syarat & Ketentuan',
                      onTap: () => Navigator.pushNamed(context, '/terms'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // KELUAR BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        // Navigation is handled by main.dart onAuthStateChange
                      },
                      icon: const Icon(Icons.logout, color: Color(0xFFC62828)),
                      label: const Text(
                        'KELUAR',
                        style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE), // Light red
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF0F3D1B),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
