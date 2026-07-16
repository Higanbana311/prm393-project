import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/tutorial_service.dart';
import '../services/settings_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final int _tab = 1;

  String _query = '';
  Timer? _debounce;

  List<TutorialData> _results = [];
  bool _searching = false;
  bool _searched = false;

  List<String> _recentSearches = [];

  static const _popularSearches = [
    'Hạc giấy',
    'Hoa sen',
    'Máy bay',
    'Bướm',
    'Rồng',
    'Ngôi sao',
    'Hộp quà',
    'Thuyền giấy',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final list = await SettingsService.instance.getRecentSearches();
    if (mounted) setState(() => _recentSearches = list);
  }

  void _onChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    final term = value.trim();
    if (term.isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(term));
  }

  Future<void> _runSearch(String term, {bool saveHistory = false}) async {
    setState(() => _searching = true);
    try {
      final list = await TutorialService.instance.search(term);
      if (mounted) {
        setState(() {
          _results = list;
          _searching = false;
          _searched = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _results = [];
          _searching = false;
          _searched = true;
        });
      }
    }
    if (saveHistory) {
      final updated = await SettingsService.instance.addRecentSearch(term);
      if (mounted) setState(() => _recentSearches = updated);
    }
  }

  void _submit([String? term]) {
    final t = (term ?? _controller.text).trim();
    if (t.isEmpty) return;
    _debounce?.cancel();
    if (_controller.text != t) _controller.text = t;
    setState(() => _query = t);
    _runSearch(t, saveHistory: true);
  }

  Future<void> _removeRecent(String term) async {
    final updated = await SettingsService.instance.removeRecentSearch(term);
    if (mounted) setState(() => _recentSearches = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: GradientAppBar(title: 'Tìm kiếm', showBack: true),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm mẫu Origami...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9B9B9B),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9B9B9B)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF9B9B9B)),
                        onPressed: () {
                          _debounce?.cancel();
                          _controller.clear();
                          setState(() {
                            _query = '';
                            _results = [];
                            _searched = false;
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.trim().isEmpty
                ? _SearchSuggestions(
                    recentSearches: _recentSearches,
                    popularSearches: _popularSearches,
                    onTap: _submit,
                    onRemoveRecent: _removeRecent,
                  )
                : _SearchResults(
                    query: _query.trim(),
                    results: _results,
                    loading: _searching,
                    searched: _searched,
                    onTapResult: (t) => Navigator.of(context)
                        .pushNamed(AppRoutes.detail, arguments: t),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pop();
          } else if (i == 1) {
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.search,
            );
          } else if (i == 2) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
          }
        },
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({
    required this.recentSearches,
    required this.popularSearches,
    required this.onTap,
    required this.onRemoveRecent,
  });

  final List<String> recentSearches;
  final List<String> popularSearches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemoveRecent;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Text(
            'Tìm kiếm gần đây',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...recentSearches.map(
            (term) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, size: 20, color: Color(0xFF9B9B9B)),
              title: Text(
                term,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18, color: Color(0xFF9B9B9B)),
                onPressed: () => onRemoveRecent(term),
              ),
              onTap: () => onTap(term),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Tìm kiếm phổ biến',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularSearches
              .map(
                (term) => GestureDetector(
                  onTap: () => onTap(term),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      term,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.results,
    required this.loading,
    required this.searched,
    required this.onTapResult,
  });

  final String query;
  final List<TutorialData> results;
  final bool loading;
  final bool searched;
  final ValueChanged<TutorialData> onTapResult;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: kPurple));
    }
    if (searched && results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(
              'Không tìm thấy mẫu cho "$query"',
              style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        Text(
          'Kết quả (${results.length})',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...results.map(
          (t) => TutorialCard(data: t, onTap: () => onTapResult(t)),
        ),
      ],
    );
  }
}
