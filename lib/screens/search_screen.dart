import 'package:flutter/material.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  static const _recentSearches = [
    'Hạc giấy truyền thống',
    'Bướm nhiều màu',
    'Hoa sen',
  ];

  static const _popularSearches = [
    'Hạc giấy',
    'Hoa hồng',
    'Máy bay',
    'Bướm',
    'Rồng',
    'Ngôi sao',
    'Hộp quà',
    'Thuyền giấy',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm mẫu Origami...',
                hintStyle:
                    const TextStyle(color: Color(0xFF9B9B9B), fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF9B9B9B)),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF9B9B9B)),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _SearchSuggestions(
                    recentSearches: _recentSearches,
                    popularSearches: _popularSearches,
                    onTap: (term) {
                      _controller.text = term;
                      setState(() => _query = term);
                    },
                  )
                : _SearchResults(query: _query),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({
    required this.recentSearches,
    required this.popularSearches,
    required this.onTap,
  });

  final List<String> recentSearches;
  final List<String> popularSearches;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tìm kiếm gần đây',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 12),
        ...recentSearches.map(
          (term) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(term,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF374151))),
            trailing: const Icon(Icons.search,
                size: 18, color: Color(0xFF9B9B9B)),
            onTap: () => onTap(term),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tìm kiếm phổ biến',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E)),
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
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(term,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151))),
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
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, size: 64, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          Text(
            'Kết quả cho "$query"',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
