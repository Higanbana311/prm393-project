import 'package:flutter/material.dart';
import '../main.dart';
import '../services/favorite_service.dart';
import '../widgets/share_sheet.dart';

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
          onTap: () => showShareSheet(
            context,
            tutorialId: widget.data.id,
            title: widget.data.title,
          ),
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
