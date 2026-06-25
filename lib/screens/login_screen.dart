import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      _showError('Vui lòng nhập email và mật khẩu');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(email, password);
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } catch (e) {
      if (mounted) _showError(AuthService.instance.dioErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9747FF)),
                ),
              ),
              const SizedBox(height: 32),
              const Text('Email',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _TextField(
                controller: _emailCtrl,
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text('Mật khẩu',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _TextField(
                controller: _passCtrl,
                hint: '••••••••',
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: const Color(0xFF9B9B9B),
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 28),
              _loading
                  ? const Center(child: CircularProgressIndicator(color: kPurple))
                  : GradientButton(label: 'Đăng nhập', onPressed: _login),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    'Tiếp tục với tư cách khách',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.register),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Chưa có tài khoản? ',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      children: [
                        TextSpan(
                          text: 'Đăng ký ngay',
                          style: TextStyle(
                            color: Color(0xFF9747FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFFD1D5DB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Hoặc',
              style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13)),
        ),
        Expanded(child: Divider(color: Color(0xFFD1D5DB))),
      ],
    );
  }
}
