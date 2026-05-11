import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/main');
    }
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
