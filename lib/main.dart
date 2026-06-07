import 'package:flutter/material.dart';

void main() {
  runApp(const OrigamiApp());
}

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
}

const _purple = Color(0xFF8B2FC9);
const _pink = Color(0xFFE91E8C);
const _splashGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF8B2FC9), Color(0xFFD91E8C), Color(0xFFFF6035)],
);

const _btnGradient = LinearGradient(
  colors: [Color(0xFF9747FF), Color(0xFFE91E8C)],
);

class OrigamiApp extends StatelessWidget {
  const OrigamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Origami',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _purple),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}

// ─── Splash ──────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: _splashGradient),
        child: Center(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            child: const _SplashContent(),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF3E0),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
          child: Image.network(
            'https://picsum.photos/seed/origami/200/200',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.catching_pokemon, size: 64, color: Color(0xFFFF8F00)),
          ),
        ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Origami',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nghệ thuật gấp giấy',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}

// ─── Onboarding ──────────────────────────────────────────────────────────────

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
                          child: const Icon(Icons.catching_pokemon, size: 120, color: Color(0xFFFF8F00)),
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
              _GradientButton(
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

// ─── Login ───────────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

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
              const Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _InputField(
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              const Text(
                'Mật khẩu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _PasswordField(
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 28),
              _GradientButton(
                label: 'Đăng nhập',
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home),
              ),
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
                      borderRadius: BorderRadius.circular(30),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.hint, this.keyboardType});

  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.obscure, required this.onToggle});

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: '••••••••',
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF9B9B9B),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFD1D5DB))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Hoặc',
            style: TextStyle(color: Color(0xFF9B9B9B), fontSize: 13),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFFD1D5DB))),
      ],
    );
  }
}

// ─── Home ─────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  static const _tutorials = [
    _TutorialData(
      title: 'Hạc giấy truyền thống',
      difficulty: 'Dễ',
      difficultyColor: Color(0xFF16A34A),
      difficultyBg: Color(0xFFDCFCE7),
      rating: 4.8,
      imageUrl: 'https://picsum.photos/seed/crane-paper/600/360',
    ),
    _TutorialData(
      title: 'Bướm nhiều màu',
      difficulty: 'Trung bình',
      difficultyColor: Color(0xFFD97706),
      difficultyBg: Color(0xFFFEF3C7),
      rating: 4.5,
      imageUrl: 'https://picsum.photos/seed/butterfly-paper/600/360',
    ),
    _TutorialData(
      title: 'Hoa sen giấy',
      difficulty: 'Dễ',
      difficultyColor: Color(0xFF16A34A),
      difficultyBg: Color(0xFFDCFCE7),
      rating: 4.7,
      imageUrl: 'https://picsum.photos/seed/lotus-paper/600/360',
    ),
    _TutorialData(
      title: 'Thuyền giấy cổ điển',
      difficulty: 'Dễ',
      difficultyColor: Color(0xFF16A34A),
      difficultyBg: Color(0xFFDCFCE7),
      rating: 4.6,
      imageUrl: 'https://picsum.photos/seed/boat-paper/600/360',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _HomeAppBar(
          onBellTap: () {},
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nổi bật',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Color(0xFF9747FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...(_tutorials.map((t) => _TutorialCard(data: t))),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 2) {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          } else {
            setState(() => _tab = i);
          }
        },
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.onBellTap});

  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _splashGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Origami',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: onBellTap,
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.data});

  final _TutorialData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              data.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: double.infinity,
                height: 180,
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _DifficultyBadge(
                      label: data.difficulty,
                      color: data.difficultyColor,
                      bg: data.difficultyBg,
                    ),
                    const Spacer(),
                    Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      data.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: _purple,
      unselectedItemColor: const Color(0xFF9B9B9B),
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Tìm kiếm'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
      ],
    );
  }
}

// ─── Profile ─────────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _ProfileAppBar(onBack: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuItem(
                icon: Icons.bookmark_outline,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: _purple,
                title: 'Origami của tôi',
                subtitle: 'Xem các mẫu đã lưu',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _MenuItem(
                icon: Icons.favorite_outline,
                iconBg: const Color(0xFFFCE7F3),
                iconColor: _pink,
                title: 'Yêu thích',
                subtitle: 'Mẫu Origami yêu thích',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'Cài đặt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9B9B9B),
                  ),
                ),
              ),
              _ToggleMenuItem(
                icon: Icons.dark_mode_outlined,
                title: 'Chế độ tối',
                value: _darkMode,
                onChanged: (v) => setState(() => _darkMode = v),
              ),
              const Divider(height: 1, indent: 56),
              _ToggleMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: _splashGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                'Hồ sơ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: _btnGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'NĐ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người Dùng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'user@example.com',
                style: TextStyle(fontSize: 13, color: Color(0xFF9B9B9B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF9B9B9B)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB)),
      onTap: onTap,
    );
  }
}

class _ToggleMenuItem extends StatelessWidget {
  const _ToggleMenuItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF6B7280)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _purple,
            activeTrackColor: Color.fromRGBO(139, 47, 201, 0.4),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _btnGradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _TutorialData {
  const _TutorialData({
    required this.title,
    required this.difficulty,
    required this.difficultyColor,
    required this.difficultyBg,
    required this.rating,
    required this.imageUrl,
  });

  final String title;
  final String difficulty;
  final Color difficultyColor;
  final Color difficultyBg;
  final double rating;
  final String imageUrl;
}
