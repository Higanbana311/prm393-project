import 'package:flutter/material.dart';
import '../main.dart';
import '../services/tutorial_service.dart';
import '../services/notification_service.dart';
import '../services/origami_service.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  List<TutorialData> _featured = [];
  List<TutorialData> _newDesigns = [];
  bool _loading = true;
  String? _error;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      // Tôn trọng tuỳ chọn: tắt thông báo thì không hiện badge
      final enabled = await SettingsService.instance.getNotifications();
      if (!enabled) {
        if (mounted) setState(() => _unreadCount = 0);
        return;
      }
      final data = await NotificationService.instance.getAll();
      if (mounted) {
        setState(() => _unreadCount = data.where((n) => !n.isRead).length);
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    OrigamiService.instance.refreshCompleted();
    try {
      final results = await Future.wait([
        TutorialService.instance.getFeatured(),
        TutorialService.instance.getNewDesigns(),
      ]);
      if (mounted) {
        setState(() {
          _featured = results[0];
          _newDesigns = results[1];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Không thể tải dữ liệu'; });
    }
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationsSheet(),
    ).then((_) => _loadUnreadCount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(
          title: 'Origami',
          actions: [
            Stack(
              children: [
                IconButton(
                  onPressed: () => _showNotifications(context),
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 26),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      child: Center(
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: _buildBody(),
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

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: kPurple));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: kPurple,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _SectionHeader(
            title: 'Nổi bật',
            onViewAll: () => Navigator.of(context).pushNamed(AppRoutes.category),
          ),
          const SizedBox(height: 8),
          ..._featured.map(
            (t) => TutorialCard(
              data: t,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.detail, arguments: t),
            ),
          ),
          const SizedBox(height: 8),
          _SectionHeader(
            title: 'Thiết kế mới',
            onViewAll: () => Navigator.of(context).pushNamed(AppRoutes.category),
          ),
          const SizedBox(height: 12),
          ..._newDesigns.map(
            (t) => _HorizontalTutorialCard(
              data: t,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.detail, arguments: t),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  List<AppNotification> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await NotificationService.instance.getAll();
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    try {
      await NotificationService.instance.markRead(n.id);
      if (mounted) {
        setState(() {
          final idx = _items.indexWhere((x) => x.id == n.id);
          if (idx != -1) {
            _items[idx] = AppNotification(
              id: n.id, title: n.title, body: n.body,
              icon: n.icon, isRead: true, createdAt: n.createdAt,
            );
          }
        });
      }
    } catch (_) {}
  }

  static IconData _iconData(String icon) {
    switch (icon) {
      case 'star':        return Icons.star_outline;
      case 'fire':        return Icons.local_fire_department_outlined;
      case 'trophy':      return Icons.emoji_events_outlined;
      case 'person_add':  return Icons.person_add_outlined;
      case 'bookmark':    return Icons.bookmark_outline;
      case 'check':       return Icons.check_circle_outline;
      default:            return Icons.notifications_outlined;
    }
  }

  static Color _iconColor(String icon) {
    switch (icon) {
      case 'star':        return const Color(0xFFD97706);
      case 'fire':        return const Color(0xFFEA580C);
      case 'trophy':      return const Color(0xFF8B2FC9);
      case 'person_add':  return const Color(0xFF0284C7);
      case 'bookmark':    return const Color(0xFF16A34A);
      default:            return const Color(0xFF8B2FC9);
    }
  }

  static Color _iconBg(String icon) {
    switch (icon) {
      case 'star':        return const Color(0xFFFEF3C7);
      case 'fire':        return const Color(0xFFFFF7ED);
      case 'trophy':      return const Color(0xFFEDE9FE);
      case 'person_add':  return const Color(0xFFE0F2FE);
      case 'bookmark':    return const Color(0xFFDCFCE7);
      default:            return const Color(0xFFEDE9FE);
    }
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24)   return '${diff.inHours} giờ trước';
    if (diff.inDays == 1)    return 'Hôm qua';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Thông báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: kPurple)),
          )
        else if (_items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Không có thông báo nào',
                style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
              ),
            ),
          )
        else
          ..._items.map(
            (n) => ListTile(
              onTap: () => _markRead(n),
              tileColor: n.isRead ? null : kPurple.withValues(alpha: 0.04),
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _iconBg(n.icon),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconData(n.icon), color: _iconColor(n.icon), size: 22),
              ),
              title: Text(
                n.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
              subtitle: Text(
                n.body,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeAgo(n.createdAt),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF9B9B9B)),
                  ),
                  if (!n.isRead) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: kPurple, shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: data.localImageAsset != null
                      ? Image.asset(data.localImageAsset!,
                          width: 80, height: 80, fit: BoxFit.cover)
                      : Image.network(
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
                Positioned(
                  top: 4,
                  left: 4,
                  child: CompletedBuilder(
                    tutorialId: data.id,
                    builder: (_, completed) => completed
                        ? const CompletedBadge(compact: true)
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
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
