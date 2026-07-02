import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/category_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/tutorial_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/register_screen.dart';
import 'screens/my_origami_screen.dart';
import 'screens/favorites_screen.dart';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const OrigamiApp());
}

// ─── Routes ──────────────────────────────────────────────────────────────────

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const category = '/category';
  static const detail = '/detail';
  static const search = '/search';
  static const profile = '/profile';
  static const tutorial = '/tutorial';
  static const friends = '/friends';
  static const register = '/register';
  static const myOrigami = '/my-origami';
  static const favorites = '/favorites';
}

// ─── Theme constants ─────────────────────────────────────────────────────────

const kPurple = Color(0xFF8B2FC9);
const kPink = Color(0xFFE91E8C);

const kSplashGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF8B2FC9), Color(0xFFD91E8C), Color(0xFFFF6035)],
);

const kBtnGradient = LinearGradient(
  colors: [Color(0xFF9747FF), Color(0xFFE91E8C)],
);

// ─── Models ──────────────────────────────────────────────────────────────────

class TutorialStep {
  const TutorialStep({
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String description;
  final String imageAsset;

  factory TutorialStep.fromJson(Map<String, dynamic> j) => TutorialStep(
        title: j['Title'] as String,
        description: j['Description'] as String,
        imageAsset: j['ImageAsset'] as String,
      );
}

class TutorialData {
  const TutorialData({
    this.id,
    required this.title,
    required this.difficulty,
    required this.difficultyColor,
    required this.difficultyBg,
    required this.rating,
    required this.imageUrl,
    this.steps = 0,
    this.minutes = '',
    this.tags = const [],
    this.description = '',
    this.localImageAsset,
    this.tutorialSteps = const [],
  });

  final int? id;
  final String title;
  final String difficulty;
  final Color difficultyColor;
  final Color difficultyBg;
  final double rating;
  final String imageUrl;
  final int steps;
  final String minutes;
  final List<String> tags;
  final String description;
  final String? localImageAsset;
  final List<TutorialStep> tutorialSteps;

  factory TutorialData.fromJson(Map<String, dynamic> j) => TutorialData(
        id: j['Id'] as int?,
        title: j['Title'] as String,
        difficulty: j['Difficulty'] as String,
        difficultyColor: _hexColor(j['DifficultyColor'] as String),
        difficultyBg: _hexColor(j['DifficultyBg'] as String),
        rating: (j['Rating'] as num).toDouble(),
        imageUrl: j['ImageUrl'] as String? ?? '',
        localImageAsset: j['LocalImageAsset'] as String?,
        steps: j['StepCount'] as int? ?? 0,
        minutes: j['Duration'] as String? ?? '',
        description: j['Description'] as String? ?? '',
        tags: (j['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        tutorialSteps: (j['tutorialSteps'] as List<dynamic>?)
                ?.map((s) => TutorialStep.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );

  static Color _hexColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

class CategoryData {
  const CategoryData({
    this.id,
    required this.name,
    required this.emoji,
    this.count = 0,
    required this.bgColor,
  });

  final int? id;
  final String name;
  final String emoji;
  final int count;
  final Color bgColor;

  factory CategoryData.fromJson(Map<String, dynamic> j) => CategoryData(
        id: j['Id'] as int?,
        name: j['Name'] as String,
        emoji: j['Emoji'] as String,
        bgColor: TutorialData._hexColor(j['BgColor'] as String),
      );
}

// ─── Sample data ─────────────────────────────────────────────────────────────

final kFeaturedTutorials = [
  const TutorialData(
    title: 'Hoa sen',
    difficulty: 'Khó',
    difficultyColor: Color(0xFFEA580C),
    difficultyBg: Color(0xFFFFF7ED),
    rating: 4.9,
    imageUrl: 'https://picsum.photos/seed/lotus-flower/600/360',
    localImageAsset: 'assets/images/lotus.jpg',
    steps: 16,
    minutes: '20-30 phút',
    tags: ['Khó', 'Giấy', 'Hoa', 'Nghệ thuật'],
    description:
        'Hoa sen (荷花) là biểu tượng của sự thuần khiết và giác ngộ trong văn hóa châu Á. Mẫu origami này tái hiện vẻ đẹp tinh tế của hoa sen qua từng nếp gấp.',
  ),
  const TutorialData(
    title: 'Hạc giấy truyền thống',
    difficulty: 'Dễ',
    difficultyColor: Color(0xFF16A34A),
    difficultyBg: Color(0xFFDCFCE7),
    rating: 4.8,
    imageUrl: 'https://picsum.photos/seed/crane-paper/600/360',
    localImageAsset: 'assets/images/crane.jpg',
    steps: 28,
    minutes: '15-20 phút',
    tags: ['Dễ', 'Giấy', 'Động vật', 'Truyền thống'],
    description:
        'Hạc giấy (折鶴, orizuru) là một trong những mẫu origami truyền thống và nổi tiếng nhất của Nhật Bản. Theo truyền thuyết, người gấp được 1000 con hạc giấy sẽ được thực hiện một điều ước.',
  ),
];

final kNewDesigns = [
  const TutorialData(
    title: 'Rồng thần thoại',
    difficulty: 'Rất khó',
    difficultyColor: Color(0xFFDC2626),
    difficultyBg: Color(0xFFFEE2E2),
    rating: 5.0,
    imageUrl: 'https://picsum.photos/seed/dragon-origami/600/360',
    steps: 45,
    minutes: '45-60 phút',
    tags: ['Rất khó', 'Giấy', 'Động vật', 'Thần thoại'],
    description: 'Rồng thần thoại – tác phẩm origami phức tạp với nhiều chi tiết tinh xảo.',
  ),
  const TutorialData(
    title: 'Máy bay chiến đấu',
    difficulty: 'Dễ',
    difficultyColor: Color(0xFF16A34A),
    difficultyBg: Color(0xFFDCFCE7),
    rating: 4.3,
    imageUrl: 'https://picsum.photos/seed/fighter-plane/600/360',
    steps: 12,
    minutes: '10-15 phút',
    tags: ['Dễ', 'Giấy', 'Máy bay'],
    description: 'Mẫu máy bay chiến đấu cổ điển, dễ gấp và có thể bay xa.',
  ),
  const TutorialData(
    title: 'Bướm nhiều màu',
    difficulty: 'Trung bình',
    difficultyColor: Color(0xFFD97706),
    difficultyBg: Color(0xFFFEF3C7),
    rating: 4.5,
    imageUrl: 'https://picsum.photos/seed/butterfly-paper/600/360',
    steps: 18,
    minutes: '15-20 phút',
    tags: ['Trung bình', 'Giấy', 'Động vật'],
    description: 'Bướm giấy nhiều màu sắc, trang trí đẹp mắt.',
  ),
];

final myOrigamiNotifier = ValueNotifier<List<TutorialData>>([
  kFeaturedTutorials[0],
]);

final favoritesNotifier = ValueNotifier<List<TutorialData>>([
  kFeaturedTutorials[1],
  kNewDesigns[0],
]);

const kCategories = [
  CategoryData(name: 'Động vật', emoji: '🦢', count: 25, bgColor: Color(0xFFEEF2FF)),
  CategoryData(name: 'Hoa', emoji: '🌸', count: 18, bgColor: Color(0xFFFCE7F3)),
  CategoryData(name: 'Máy bay', emoji: '✈️', count: 12, bgColor: Color(0xFFE0F2FE)),
  CategoryData(name: 'Hộp', emoji: '📦', count: 15, bgColor: Color(0xFFFEF3C7)),
  CategoryData(name: 'Ngôi sao', emoji: '⭐', count: 10, bgColor: Color(0xFFFFFBEB)),
  CategoryData(name: 'Tim', emoji: '❤️', count: 8, bgColor: Color(0xFFFFF1F2)),
  CategoryData(name: 'Rồng', emoji: '🐉', count: 6, bgColor: Color(0xFFECFDF5)),
  CategoryData(name: 'Thuyền', emoji: '⛵', count: 14, bgColor: Color(0xFFEFF6FF)),
];

// ─── Friends data ─────────────────────────────────────────────────────────────

class Friend {
  const Friend({
    this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.color,
    required this.completed,
    this.nickname = '',
    this.hasPendingRequest = false,
  });

  final int? id;
  final String name;
  final String email;
  final String initials;
  final Color color;
  final int completed;
  final String nickname;
  final bool hasPendingRequest;

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
        id: j['Id'] as int?,
        name: j['FullName'] as String,
        email: j['Email'] as String? ?? '',
        initials: j['AvatarInitials'] as String? ?? '',
        color: TutorialData._hexColor(j['AvatarColor'] as String? ?? '#8B2FC9'),
        completed: j['Completed'] as int? ?? 0,
        nickname: j['Nickname'] as String? ?? '',
        hasPendingRequest: (j['HasPendingRequest'] as int? ?? 0) == 1,
      );
}

class FriendRequest {
  const FriendRequest({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderNickname,
    required this.senderInitials,
    required this.senderColor,
    required this.completed,
    required this.createdAt,
  });

  final int id;
  final int senderId;
  final String senderName;
  final String senderNickname;
  final String senderInitials;
  final Color senderColor;
  final int completed;
  final DateTime createdAt;

  String get displayName => senderNickname.isNotEmpty ? senderNickname : senderName;

  factory FriendRequest.fromJson(Map<String, dynamic> j) => FriendRequest(
        id: j['Id'] as int,
        senderId: j['SenderId'] as int,
        senderName: j['FullName'] as String,
        senderNickname: j['Nickname'] as String? ?? '',
        senderInitials: j['AvatarInitials'] as String? ?? '',
        senderColor: TutorialData._hexColor(j['AvatarColor'] as String? ?? '#8B2FC9'),
        completed: j['Completed'] as int? ?? 0,
        createdAt: DateTime.tryParse(j['CreatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String icon;
  final bool isRead;
  final DateTime createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['Id'] as int,
        title: j['Title'] as String,
        body: j['Body'] as String,
        icon: j['Icon'] as String? ?? 'notifications',
        isRead: j['IsRead'] == true || j['IsRead'] == 1,
        createdAt: DateTime.tryParse(j['CreatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

const kMockFriends = [
  Friend(
    name: 'Yến Nhi',
    email: 'yennhi@example.com',
    initials: 'YN',
    color: Color(0xFF8B2FC9),
    completed: 12,
  ),
  Friend(
    name: 'Lan Anh',
    email: 'lananh@example.com',
    initials: 'LA',
    color: Color(0xFFE91E8C),
    completed: 7,
  ),
  Friend(
    name: 'Đức Khoa',
    email: 'duckhoa@example.com',
    initials: 'ĐK',
    color: Color(0xFF0284C7),
    completed: 23,
  ),
  Friend(
    name: 'Thu Hà',
    email: 'thuha@example.com',
    initials: 'TH',
    color: Color(0xFF16A34A),
    completed: 5,
  ),
];

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: kBtnGradient,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: kPurple,
      unselectedItemColor: const Color(0xFF9B9B9B),
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.search_outlined), label: 'Tìm kiếm'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
      ],
    );
  }
}

class GradientAppBar extends StatelessWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions = const [],
  });

  final String title;
  final bool showBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kSplashGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              else
                const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

class TutorialCard extends StatelessWidget {
  const TutorialCard({super.key, required this.data, this.onTap});

  final TutorialData data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: data.localImageAsset != null
                  ? Image.asset(
                      data.localImageAsset!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      data.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: double.infinity,
                        height: 180,
                        color: const Color(0xFFF3F4F6),
                        child: const Icon(Icons.image_outlined, size: 48, color: Color(0xFFD1D5DB)),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      DifficultyBadge(
                        label: data.difficulty,
                        color: data.difficultyColor,
                        bg: data.difficultyBg,
                      ),
                      const Spacer(),
                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        data.rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App ─────────────────────────────────────────────────────────────────────

class OrigamiApp extends StatelessWidget {
  const OrigamiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Origami',
        themeMode: mode,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: kPurple),
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: kPurple,
            brightness: Brightness.dark,
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.category: (_) => const CategoryScreen(),
          AppRoutes.detail: (_) => const DetailScreen(),
          AppRoutes.tutorial: (_) => const TutorialScreen(),
          AppRoutes.search: (_) => const SearchScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.friends: (_) => const FriendsScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.myOrigami: (_) => const MyOrigamiScreen(),
          AppRoutes.favorites: (_) => const FavoritesScreen(),
        },
      ),
    );
  }
}
