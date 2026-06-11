import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(
          title: 'Origami',
          actions: [
            IconButton(
              onPressed: () => _showNotifications(context),
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _SectionHeader(
            title: 'Nổi bật',
            onViewAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.category),
          ),
          const SizedBox(height: 8),
          ...kFeaturedTutorials.map(
            (t) => TutorialCard(
              data: t,
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.detail, arguments: t),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'Thiết kế mới',
            onViewAll: () =>
                Navigator.of(context).pushNamed(AppRoutes.category),
          ),
          const SizedBox(height: 12),
          ...kNewDesigns.map(
            (t) => _HorizontalTutorialCard(
              data: t,
              onTap: () => Navigator.of(context)
                  .pushNamed(AppRoutes.detail, arguments: t),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).pushNamed(AppRoutes.search);
          } else if (i == 2) {
            Navigator.of(context).pushNamed(AppRoutes.profile);
          } else {
            setState(() => _tab = i);
          }
        },
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  static const _items = [
    (
      icon: Icons.star_outline,
      color: Color(0xFFD97706),
      bg: Color(0xFFFEF3C7),
      title: 'Hoa sen được yêu thích',
      body: 'Mẫu Hoa sen vừa nhận được đánh giá 5 sao mới!',
      time: '5 phút trước',
    ),
    (
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFEA580C),
      bg: Color(0xFFFFF7ED),
      title: 'Nội dung mới',
      body: 'Hướng dẫn "Rồng thần thoại" vừa được cập nhật thêm bước.',
      time: '1 giờ trước',
    ),
    (
      icon: Icons.emoji_events_outlined,
      color: Color(0xFF8B2FC9),
      bg: Color(0xFFEDE9FE),
      title: 'Chúc mừng!',
      body: 'Bạn đã hoàn thành 3 hướng dẫn. Tiếp tục nhé!',
      time: 'Hôm qua',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Thông báo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ..._items.map(
          (n) => ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.icon, color: n.color, size: 22),
            ),
            title: Text(
              n.title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              n.body,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              n.time,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9B9B9B)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            'Xem tất cả',
            style: TextStyle(color: kPurple, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _HorizontalTutorialCard extends StatelessWidget {
  const _HorizontalTutorialCard({required this.data, this.onTap});

  final TutorialData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.image_outlined,
                      size: 32, color: Color(0xFFD1D5DB)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      DifficultyBadge(
                        label: data.difficulty,
                        color: data.difficultyColor,
                        bg: data.difficultyBg,
                      ),
                      const Spacer(),
                      Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        data.rating.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
