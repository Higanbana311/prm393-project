import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
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
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _loadPendingCount();
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

  Future<void> _loadPendingCount() async {
    try {
      final requests = await FriendService.instance.getPendingRequests();
      if (mounted) setState(() => _pendingCount = requests.length);
    } catch (_) {}
  }

  List<Friend> get _filtered => _friends
      .where((f) =>
          f.name.toLowerCase().contains(_query.toLowerCase()) ||
          f.email.toLowerCase().contains(_query.toLowerCase()) ||
          f.nickname.toLowerCase().contains(_query.toLowerCase()))
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
            Stack(
              children: [
                IconButton(
                  onPressed: () => _showRequestsSheet(context),
                  icon: const Icon(Icons.group_add_outlined, color: Colors.white),
                ),
                if (_pendingCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_pendingCount',
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
      builder: (_) => _AddFriendSheet(onSent: () { if (mounted) _load(); }),
    );
  }

  void _showRequestsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FriendRequestsSheet(
        onChanged: () {
          if (mounted) {
            _load();
            _loadPendingCount();
          }
        },
      ),
    ).then((_) => _loadPendingCount());
  }
}

// ─── Friend Requests Sheet ────────────────────────────────────────────────────

class _FriendRequestsSheet extends StatefulWidget {
  const _FriendRequestsSheet({required this.onChanged});
  final VoidCallback onChanged;

  @override
  State<_FriendRequestsSheet> createState() => _FriendRequestsSheetState();
}

class _FriendRequestsSheetState extends State<_FriendRequestsSheet> {
  List<FriendRequest> _requests = [];
  bool _loading = true;
  final Set<int> _processing = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await FriendService.instance.getPendingRequests();
      if (mounted) setState(() { _requests = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept(FriendRequest req) async {
    setState(() => _processing.add(req.id));
    try {
      await FriendService.instance.acceptRequest(req.id);
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.id == req.id);
          _processing.remove(req.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đã kết bạn với ${req.displayName}!'),
          behavior: SnackBarBehavior.floating,
        ));
        widget.onChanged();
      }
    } catch (_) {
      if (mounted) setState(() => _processing.remove(req.id));
    }
  }

  Future<void> _reject(FriendRequest req) async {
    setState(() => _processing.add(req.id));
    try {
      await FriendService.instance.rejectRequest(req.id);
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.id == req.id);
          _processing.remove(req.id);
        });
        widget.onChanged();
      }
    } catch (_) {
      if (mounted) setState(() => _processing.remove(req.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lời mời kết bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: kPurple))
                  : _requests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 56,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.4)),
                              const SizedBox(height: 12),
                              Text(
                                'Không có lời mời nào',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _requests.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final req = _requests[i];
                            final isProcessing = _processing.contains(req.id);
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      color: req.senderColor.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        req.senderInitials.isNotEmpty
                                            ? req.senderInitials
                                            : req.senderName[0],
                                        style: TextStyle(
                                          color: req.senderColor,
                                          fontSize: 15,
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
                                          req.displayName,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        if (req.senderNickname.isEmpty)
                                          Text(
                                            req.senderName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        Text(
                                          '${req.completed} bài hoàn thành',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isProcessing)
                                    const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: kPurple),
                                    )
                                  else
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => _reject(req),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF6B7280),
                                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text('Từ chối',
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _accept(req),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPurple,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text('Chấp nhận',
                                              style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
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

// ─── Add Friend Sheet ─────────────────────────────────────────────────────────

class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet({required this.onSent});
  final VoidCallback onSent;

  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  List<Friend> _results = [];
  bool _searching = false;
  bool _searched = false;
  final Set<int> _requested = {};

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
      if (mounted) {
        final alreadySent = list
            .where((f) => f.hasPendingRequest && f.id != null)
            .map((f) => f.id!)
            .toSet();
        setState(() {
          _results = list;
          _requested.addAll(alreadySent);
          _searching = false;
          _searched = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _results = []; _searching = false; _searched = true; });
    }
  }

  Future<void> _sendRequest(Friend friend) async {
    if (friend.id == null) return;
    try {
      await FriendService.instance.sendRequest(friend.id!);
      if (mounted) {
        setState(() => _requested.add(friend.id!));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lời mời tới ${friend.nickname.isNotEmpty ? friend.nickname : friend.name}!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSent();
      }
    } catch (e) {
      if (mounted) {
        final msg = AuthService.instance.dioErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
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
                  'Thêm bạn bè',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E)),
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
                        hintText: 'Nhập nickname...',
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Tìm'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _searching
                  ? const Center(
                      child: CircularProgressIndicator(color: kPurple))
                  : !_searched
                      ? Center(
                          child: Text(
                            'Nhập nickname và nhấn Tìm',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade500),
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                'Không tìm thấy người dùng',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey.shade500),
                              ),
                            )
                          : ListView.separated(
                              controller: scrollCtrl,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _results.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, i) {
                                final user = _results[i];
                                final isRequested =
                                    _requested.contains(user.id);
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44, height: 44,
                                        decoration: BoxDecoration(
                                          color: user.color
                                              .withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            user.initials.isNotEmpty
                                                ? user.initials
                                                : user.name[0],
                                            style: TextStyle(
                                              color: user.color,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.nickname.isNotEmpty
                                                  ? user.nickname
                                                  : user.name,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            if (user.nickname.isNotEmpty)
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF9B9B9B)),
                                              ),
                                          ],
                                        ),
                                      ),
                                      isRequested
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: const [
                                                Icon(Icons.schedule,
                                                    color: Color(0xFF9B9B9B),
                                                    size: 18),
                                                SizedBox(width: 4),
                                                Text('Đã gửi',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF9B9B9B))),
                                              ],
                                            )
                                          : OutlinedButton(
                                              onPressed: () =>
                                                  _sendRequest(user),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: kPurple,
                                                side: const BorderSide(
                                                    color: kPurple),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                minimumSize: Size.zero,
                                                tapTargetSize: MaterialTapTargetSize
                                                    .shrinkWrap,
                                              ),
                                              child: const Text('+ Thêm',
                                                  style:
                                                      TextStyle(fontSize: 13)),
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

// ─── Empty State ──────────────────────────────────────────────────────────────

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

// ─── Friend Card ──────────────────────────────────────────────────────────────

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
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
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
                  friend.nickname.isNotEmpty ? friend.nickname : friend.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (friend.nickname.isNotEmpty)
                  Text(
                    friend.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
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
        ],
      ),
    );
  }
}
