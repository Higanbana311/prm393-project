import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = themeModeNotifier.value == ThemeMode.dark;
  bool _notifications = true;
  final int _tab = 2;

  String _name = '';
  String _email = '';
  String _initials = '';
  String _colorHex = '#8B2FC9';
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final info = await AuthService.instance.getUserInfo();
    if (mounted) {
      setState(() {
        _name = info['name'] ?? 'Người Dùng';
        _email = info['email'] ?? '';
        _initials = info['initials'] ?? '';
        _colorHex = info['color'] ?? '#8B2FC9';
        _nickname = info['nickname'] ?? '';
      });
    }
  }

  Future<void> _showEditNicknameDialog() async {
    final ctrl = TextEditingController(text: _nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi nickname', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 50,
          decoration: InputDecoration(
            hintText: 'Nhập nickname...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPurple,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null || result.isEmpty || result == _nickname) return;
    try {
      final updated = await AuthService.instance.updateNickname(result);
      if (mounted) setState(() => _nickname = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AuthService.instance.dioErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(title: 'Hồ sơ', showBack: true),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileHeader(
            name: _name,
            email: _email,
            initials: _initials,
            colorHex: _colorHex,
            nickname: _nickname,
            onEditNickname: _showEditNicknameDialog,
          ),
          const SizedBox(height: 16),
          _MenuCard(
            children: [
              _MenuItem(
                icon: Icons.bookmark_outline,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: kPurple,
                title: 'Origami của tôi',
                subtitle: 'Xem các mẫu đã lưu',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.myOrigami),
              ),
              const Divider(height: 1, indent: 56),
              _MenuItem(
                icon: Icons.favorite_outline,
                iconBg: const Color(0xFFFCE7F3),
                iconColor: kPink,
                title: 'Yêu thích',
                subtitle: 'Mẫu Origami yêu thích',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.favorites),
              ),
              const Divider(height: 1, indent: 56),
              _MenuItem(
                icon: Icons.people_outline,
                iconBg: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                title: 'Bạn bè',
                subtitle: 'Kết nối với bạn bè',
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.friends),
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
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  themeModeNotifier.value =
                      v ? ThemeMode.dark : ThemeMode.light;
                },
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
              onPressed: _logout,
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pop();
          } else if (i == 1) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.search);
          } else if (i == 2) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          }
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.initials,
    required this.colorHex,
    required this.nickname,
    required this.onEditNickname,
  });

  final String name;
  final String email;
  final String initials;
  final String colorHex;
  final String nickname;
  final VoidCallback onEditNickname;

  Color get _color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return const Color(0xFF8B2FC9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayInitials =
        initials.isNotEmpty ? initials : (name.isNotEmpty ? name[0] : '?');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                displayInitials,
                style: TextStyle(
                  color: _color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Người Dùng' : name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      nickname.isEmpty ? 'Chưa có nickname' : '@$nickname',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: nickname.isEmpty
                            ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                            : kPurple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onEditNickname,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
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
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(10),
        ),
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
          Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
            activeThumbColor: kPurple,
            activeTrackColor: Color.fromRGBO(139, 47, 201, 0.4),
          ),
        ],
      ),
    );
  }
}
