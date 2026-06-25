import 'package:flutter/material.dart';
import '../main.dart';
import '../services/friend_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _searchCtrl = TextEditingController();
  List<Friend> _friends = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await FriendService.instance.getAll();
      if (mounted) setState(() { _friends = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Friend> get _filtered => _friends
      .where((f) =>
          f.name.toLowerCase().contains(_query.toLowerCase()) ||
          f.email.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final friends = _filtered;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(
          title: 'Bạn bè',
          showBack: true,
          actions: [
            IconButton(
              onPressed: () => _showAddFriendDialog(context),
              icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Tìm bạn bè...',
                      prefixIcon: const Icon(Icons.search_outlined),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bạn bè (${friends.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: friends.isEmpty
                      ? _EmptyState(query: _query)
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: kPurple,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: friends.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _FriendCard(friend: friends[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddFriendSheet(
        onAdded: () {
          if (mounted) _load();
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            query.isEmpty ? Icons.people_outline : Icons.search_off_outlined,
            size: 56,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            query.isEmpty ? 'Chưa có bạn bè nào' : 'Không tìm thấy "$query"',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Thêm bạn bè bằng nút + ở góc trên',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.onAdded});
  final VoidCallback onAdded;

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  List<Friend> _results = [];
  bool _searching = false;
  bool _searched = false;
  final Set<int> _added = {};

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    setState(() { _searching = true; _searched = false; });
    try {
      final list = await FriendService.instance.searchByName(name);
      if (mounted) setState(() { _results = list; _searching = false; _searched = true; });
    } catch (_) {
      if (mounted) setState(() { _results = []; _searching = false; _searched = true; });
    }
  }

  Future<void> _add(Friend friend) async {
    if (friend.id == null) return;
    try {
      await FriendService.instance.addById(friend.id!);
      if (mounted) {
        setState(() => _added.add(friend.id!));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${friend.name} làm bạn bè!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onAdded();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thêm bạn bè, thử lại sau'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thêm bạn bè',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên người dùng...',
                        prefixIcon: const Icon(Icons.search_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Tìm'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _searching
                  ? const Center(child: CircularProgressIndicator(color: kPurple))
                  : !_searched
                      ? Center(
                          child: Text(
                            'Nhập tên và nhấn Tìm',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                'Không tìm thấy người dùng',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollCtrl,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _results.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final user = _results[i];
                                final isAdded = _added.contains(user.id);
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: user.color.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            user.initials.isNotEmpty ? user.initials : user.name[0],
                                            style: TextStyle(color: user.color, fontSize: 15, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          user.name,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      isAdded
                                          ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                                          : OutlinedButton(
                                              onPressed: () => _add(user),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: kPurple,
                                                side: const BorderSide(color: kPurple),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: const Text('+ Thêm', style: TextStyle(fontSize: 13)),
                                            ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  const _FriendCard({required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: friend.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                friend.initials,
                style: TextStyle(
                  color: friend.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${friend.completed} bài hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: kPurple,
              side: const BorderSide(color: kPurple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Nhắn tin', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
