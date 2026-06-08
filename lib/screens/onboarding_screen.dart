import 'package:flutter/material.dart';
import '../main.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://picsum.photos/seed/origami-craft/600/560',
                        width: double.infinity,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: double.infinity,
                          height: 280,
                          color: const Color(0xFFFFF3E0),
                          child: const Icon(Icons.catching_pokemon,
                              size: 120, color: Color(0xFFFF8F00)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'Khám phá Nghệ\nthuật Origami',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Học cách gấp giấy thành những tác phẩm nghệ thuật tuyệt đẹp với hướng dẫn chi tiết từng bước',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              GradientButton(
                label: 'Bắt đầu',
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
