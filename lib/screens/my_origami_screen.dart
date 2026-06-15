import 'package:flutter/material.dart';
import '../main.dart';

class MyOrigamiScreen extends StatelessWidget {
  const MyOrigamiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(title: 'Origami của tôi', showBack: true),
      ),
      body: ValueListenableBuilder<List<TutorialData>>(
        valueListenable: myOrigamiNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return const _EmptyState(
              icon: Icons.bookmark_outline,
              message: 'Chưa có mẫu nào được lưu',
              subtitle: 'Nhấn 🔖 trên bất kỳ mẫu origami nào để lưu vào đây',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.title),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                ),
                onDismissed: (_) {
                  final updated = List<TutorialData>.from(myOrigamiNotifier.value)
                    ..remove(item);
                  myOrigamiNotifier.value = updated;
                },
                child: TutorialCard(
                  data: item,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.detail,
                    arguments: item,
                  ),
                ),
              );
            },
          );
        },
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
