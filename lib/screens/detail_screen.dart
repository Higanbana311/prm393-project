import 'package:flutter/material.dart';
import '../main.dart';
import '../services/favorite_service.dart';
import '../services/friend_service.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as TutorialData?
        ?? kFeaturedTutorials.first;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _DetailSliverAppBar(data: data),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: data.tags
                            .map((tag) => _TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 18, color: Colors.amber.shade600),
                          const SizedBox(width: 4),
                          Text(
                            data.rating.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.format_list_numbered,
                              size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text('${data.steps} bước',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6B7280))),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time,
                              size: 18, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(data.minutes,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Mô tả'),
                      const SizedBox(height: 8),
                      Text(
                        data.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Lịch sử'),
                      const SizedBox(height: 8),
                      Text(
                        'Origami ${data.title.toLowerCase()} xuất hiện từ thời kỳ Edo (1603-1868) tại Nhật Bản. Nó trở thành biểu tượng của hòa bình và hy vọng, đặc biệt sau câu chuyện của Sadako Sasaki và 1000 con hạc giấy.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle(title: 'Vật liệu cần thiết'),
                      const SizedBox(height: 12),
                      const _MaterialItem(text: 'Giấy vuông (15cm x 15cm)'),
                      const _MaterialItem(text: 'Tay khéo léo'),
                      const _MaterialItem(text: 'Kiên nhẫn'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: GradientButton(
              label: '▶  Bắt đầu hướng dẫn',
              onPressed: () => Navigator.of(context)
                  .pushNamed(AppRoutes.tutorial, arguments: data),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSliverAppBar extends StatefulWidget {
  const _DetailSliverAppBar({required this.data});
  final TutorialData data;

  @override
  State<_DetailSliverAppBar> createState() => _DetailSliverAppBarState();
}

class _DetailSliverAppBarState extends State<_DetailSliverAppBar> {
  bool _isFav = false;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    if (widget.data.id == null) return;
    try {
      final favs = await FavoriteService.instance.getAll();
      if (mounted) {
        setState(() => _isFav = favs.any((t) => t.id == widget.data.id));
      }
    } catch (_) {}
  }

  Future<void> _toggleFav() async {
    if (widget.data.id == null || _toggling) return;
    setState(() { _toggling = true; _isFav = !_isFav; });
    try {
      if (_isFav) {
        await FavoriteService.instance.add(widget.data.id!);
      } else {
        await FavoriteService.instance.remove(widget.data.id!);
      }
    } catch (_) {
      if (mounted) setState(() => _isFav = !_isFav);
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 6),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
        ),
      ),
      actions: [
        _ActionButton(
          icon: _isFav ? Icons.favorite : Icons.favorite_outline,
          iconColor: _isFav ? kPink : const Color(0xFF1A1A2E),
          onTap: _toggleFav,
        ),
        const SizedBox(width: 4),
        _ActionButton(
          icon: Icons.share_outlined,
          onTap: () => _showShareSheet(context, widget.data),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.data.localImageAsset != null
            ? Image.asset(widget.data.localImageAsset!, fit: BoxFit.cover)
            : Image.network(
                widget.data.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(Icons.image_outlined,
                      size: 64, color: Color(0xFFD1D5DB)),
                ),
              ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.iconColor = const Color(0xFF1A1A2E),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Color(0x1A000000), blurRadius: 6),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: kPurple,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

void _showShareSheet(BuildContext context, TutorialData data) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ShareSheet(data: data),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.data});
  final TutorialData data;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final Set<int> _selected = {};
  List<Friend> _friends = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FriendService.instance.getAll().then((list) {
      if (mounted) setState(() { _friends = list; _loading = false; });
    }).catchError((_) {
      if (mounted) setState(() => _loading = false);
    });
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chia sẻ với bạn bè',
                style: TextStyle(
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
                widget.data.title,
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
              label: _selected.isEmpty
                  ? 'Chọn bạn bè để chia sẻ'
                  : 'Chia sẻ với ${_selected.length} người',
              onPressed: _selected.isEmpty
                  ? () {}
                  : () {
                      final names = _selected
                          .map((i) => _friends[i].name)
                          .join(', ');
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Đã chia sẻ "${widget.data.title}" với $names'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialItem extends StatelessWidget {
  const _MaterialItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                const BoxDecoration(color: kPurple, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
        ],
      ),
    );
  }
}
