import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get _isFormValid {
    final email = _emailController.text;
    final password = _passwordController.text;
    return email.isNotEmpty && email.contains('@') && password.length >= 8;
  }

  void _onFieldChanged(String _) {
    setState(() {}); // Rebuild to evaluate _isFormValid and update button state
  }

  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('email not confirmed') ||
              errorStr.contains('email_not_confirmed')) {
            // Kirim ulang email konfirmasi otomatis
            _showEmailNotConfirmedDialog();
            return;
          } else if (errorStr.contains('invalid login credentials') ||
              errorStr.contains('invalid_credentials')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Email atau kata sandi salah. Periksa kembali.'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ));
          } else if (errorStr.contains('too many requests')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Terlalu banyak percobaan login. Coba lagi nanti.'),
              backgroundColor: Colors.orange[700],
              behavior: SnackBarBehavior.floating,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Login gagal: ${e.toString()}'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showEmailNotConfirmedDialog() {
    final email = _emailController.text.trim();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool isSending = false;
          bool hasSent = false;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.mark_email_unread_outlined, color: Color(0xFF2E7D32), size: 26),
                SizedBox(width: 8),
                Text('Verifikasi Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email $email belum diverifikasi.',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '📧 Cara verifikasi:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20), fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '1. Klik tombol "Kirim Ulang Email" di bawah\n'
                        '2. Buka inbox email Anda\n'
                        '3. Klik link konfirmasi\n'
                        '4. Kembali dan login',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1B5E20), height: 1.7),
                      ),
                    ],
                  ),
                ),
                if (hasSent) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Email konfirmasi terkirim! Cek inbox Anda.',
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup', style: TextStyle(color: Colors.black45)),
              ),
              StatefulBuilder(
                builder: (ctx2, setSendState) => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isSending
                      ? null
                      : () async {
                          setSendState(() => isSending = true);
                          try {
                            await Supabase.instance.client.auth.resend(
                              type: OtpType.signup,
                              email: email,
                            );
                            setSendState(() {
                              isSending = false;
                              hasSent = true;
                            });
                            setDialogState(() => hasSent = true);
                          } catch (e) {
                            setSendState(() => isSending = false);
                            if (ctx2.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Gagal kirim email: ${e.toString()}'),
                                backgroundColor: Colors.red[700],
                              ));
                            }
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Ulang Email',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Logo
                  Image.asset(
                    'assets/pulmocarelogo.jpeg', // Using the correct asset path
                    height: 100,
                  ),
                  const SizedBox(height: 32),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2E7D32), width: 1),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Toggle
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFA5D6A7), // Light Green
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B5E20), // Dark Green active
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      Navigator.pushReplacementNamed(context, '/register');
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Daftar',
                                        style: TextStyle(
                                          color: Color(0xFF1B5E20),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Fields
                          CustomTextField(
                            label: 'Email',
                            hintText: 'nama@gmail.com',
                            controller: _emailController,
                            onChanged: _onFieldChanged,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!value.contains('@')) {
                                return 'Email harus valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Kata Sandi',
                            hintText: 'kata sandi',
                            isPassword: true,
                            controller: _passwordController,
                            onChanged: _onFieldChanged,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kata sandi tidak boleh kosong';
                              }
                              if (value.length < 8) {
                                return 'Kata sandi minimal 8 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          CustomButton(
                            text: 'Masuk',
                            onPressed: _isFormValid ? _submit : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
                      children: [
                        TextSpan(text: 'Dengan masuk, Anda menyetujui\n'),
                        TextSpan(
                          text: 'Syarat & Ketentuan',
                          style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' serta Kebijakan Privasi kami.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
