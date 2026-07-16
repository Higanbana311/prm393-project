import 'package:flutter/material.dart';
import '../main.dart';
import '../services/friend_service.dart';
import '../services/tutorial_service.dart';

/// Mở bottom sheet chia sẻ một mẫu tới bạn bè.
/// [isCompletion] = true khi chia sẻ thành tích sau khi hoàn thành.
void showShareSheet(
  BuildContext context, {
  required int? tutorialId,
  required String title,
  bool isCompletion = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ShareSheet(
      tutorialId: tutorialId,
      title: title,
      isCompletion: isCompletion,
    ),
  );
}

class ShareSheet extends StatefulWidget {
  const ShareSheet({
    super.key,
    required this.tutorialId,
    required this.title,
    this.isCompletion = false,
  });

  final int? tutorialId;
  final String title;
  final bool isCompletion;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final Set<int> _selected = {};
  List<Friend> _friends = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    FriendService.instance.getAll().then((list) {
      if (mounted) setState(() { _friends = list; _loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _share() async {
    if (_selected.isEmpty || _sending) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final selectedFriends = _selected.map((i) => _friends[i]).toList();
    final friendIds =
        selectedFriends.map((f) => f.id).whereType<int>().toList();

    // Dữ liệu mẫu không có id (mock) -> chỉ báo cục bộ, không gọi API.
    if (widget.tutorialId == null || friendIds.isEmpty) {
      final names = selectedFriends.map((f) => f.name).join(', ');
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã chia sẻ "${widget.title}" với $names'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final sent = await TutorialService.instance.share(
        widget.tutorialId!,
        friendIds,
        type: widget.isCompletion ? 'completion' : 'detail',
      );
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã chia sẻ "${widget.title}" với $sent người'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _sending = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Không thể chia sẻ. Vui lòng thử lại.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.isCompletion ? 'Chia sẻ thành tích' : 'Chia sẻ với bạn bè',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.isCompletion
                    ? 'Bạn vừa hoàn thành "${widget.title}"'
                    : widget.title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: kPurple),
            )
          else if (_friends.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Chưa có bạn bè nào',
                style: TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _friends.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (_, i) {
                  final friend = _friends[i];
                  final selected = _selected.contains(i);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: friend.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          friend.initials,
                          style: TextStyle(
                            color: friend.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      friend.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${friend.completed} bài hoàn thành',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Checkbox(
                      value: selected,
                      activeColor: kPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selected.add(i);
                        } else {
                          _selected.remove(i);
                        }
                      }),
                    ),
                    onTap: () => setState(() {
                      if (_selected.contains(i)) {
                        _selected.remove(i);
                      } else {
                        _selected.add(i);
                      }
                    }),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: GradientButton(
              label: _sending
                  ? 'Đang chia sẻ...'
                  : _selected.isEmpty
                      ? 'Chọn bạn bè để chia sẻ'
                      : 'Chia sẻ với ${_selected.length} người',
              onPressed: (_selected.isEmpty || _sending) ? () {} : _share,
            ),
          ),
        ],
      ),
    );
  }
}
