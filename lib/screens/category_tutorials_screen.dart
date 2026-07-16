import 'package:flutter/material.dart';
import '../main.dart';
import '../services/tutorial_service.dart';

class CategoryTutorialsScreen extends StatefulWidget {
  const CategoryTutorialsScreen({super.key});

  @override
  State<CategoryTutorialsScreen> createState() =>
      _CategoryTutorialsScreenState();
}

class _CategoryTutorialsScreenState extends State<CategoryTutorialsScreen> {
  List<TutorialData> _tutorials = [];
  bool _loading = true;
  CategoryData? _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_category == null) {
      _category = ModalRoute.of(context)!.settings.arguments as CategoryData?;
      _load();
    }
  }

  Future<void> _load() async {
    final id = _category?.id;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await TutorialService.instance.getByCategory(id);
      if (mounted) setState(() { _tutorials = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _category?.name ?? 'Thể loại';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(title: title, showBack: true),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPurple))
          : _tutorials.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _category?.emoji ?? '📄',
                        style: const TextStyle(fontSize: 56),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có mẫu nào trong thể loại này',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: kPurple,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Text(
                        '${_tutorials.length} mẫu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._tutorials.map(
                        (t) => TutorialCard(
                          data: t,
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.detail, arguments: t),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
