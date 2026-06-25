import 'package:flutter/material.dart';
import '../main.dart';
import '../services/origami_service.dart';

class MyOrigamiScreen extends StatefulWidget {
  const MyOrigamiScreen({super.key});

  @override
  State<MyOrigamiScreen> createState() => _MyOrigamiScreenState();
}

class _MyOrigamiScreenState extends State<MyOrigamiScreen> {
  List<TutorialData> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await OrigamiService.instance.getAll();
      if (mounted) setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(TutorialData item) async {
    if (item.id == null) return;
    setState(() => _items.remove(item));
    try {
      await OrigamiService.instance.remove(item.id!);
    } catch (_) {
      if (mounted) setState(() => _items.insert(0, item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(title: 'Origami của tôi', showBack: true),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : _items.isEmpty
              ? const _EmptyState(
                  icon: Icons.bookmark_outline,
                  message: 'Chưa có mẫu nào được lưu',
                  subtitle: 'Hoàn thành một hướng dẫn để thêm vào đây',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kPurple,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Dismissible(
                        key: ValueKey(item.id ?? item.title),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => _remove(item),
                        child: TutorialCard(
                          data: item,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.detail, arguments: item),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
  });

  final IconData icon;
  final String message;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 40, color: kPurple),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9B9B9B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
