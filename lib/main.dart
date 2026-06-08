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
}

class TutorialData {
  const TutorialData({
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
}

class CategoryData {
  const CategoryData({
    required this.name,
    required this.emoji,
    required this.count,
    required this.bgColor,
  });

  final String name;
  final String emoji;
  final int count;
  final Color bgColor;
}

// ─── Sample data ─────────────────────────────────────────────────────────────

const kLotusSteps = [
  TutorialStep(
    title: 'Chuẩn bị giấy vuông',
    description: 'Bắt đầu với một tờ giấy hình vuông. Đặt giấy với mặt màu hướng xuống dưới.',
    imageAsset: 'assets/images/lotus_step/step-1.png',
  ),
  TutorialStep(
    title: 'Gấp đôi theo chiều ngang',
    description: 'Gấp tờ giấy làm đôi từ trái sang phải tạo thành hình chữ nhật. Miết phẳng rồi mở ra.',
    imageAsset: 'assets/images/lotus_step/step-2.png',
  ),
  TutorialStep(
    title: 'Gấp đôi theo chiều dọc',
    description: 'Gấp tờ giấy làm đôi từ trên xuống dưới. Miết phẳng rồi mở ra để tạo nếp gấp.',
    imageAsset: 'assets/images/lotus_step/step-3.png',
  ),
  TutorialStep(
    title: 'Gấp theo đường chéo',
    description: 'Gấp tờ giấy theo đường chéo từ góc trái dưới lên góc phải trên. Miết phẳng rồi mở ra.',
    imageAsset: 'assets/images/lotus_step/step-4.png',
  ),
  TutorialStep(
    title: 'Gấp chéo ngược',
    description: 'Gấp theo đường chéo còn lại từ góc phải dưới lên góc trái trên. Mở ra để có đủ 4 nếp gấp.',
    imageAsset: 'assets/images/lotus_step/step-5.png',
  ),
  TutorialStep(
    title: 'Thu gọn thành hình vuông',
    description: 'Sử dụng các nếp gấp sẵn có để thu gấp tờ giấy thành hình vuông nhỏ hơn với 4 lớp.',
    imageAsset: 'assets/images/lotus_step/step-6.png',
  ),
  TutorialStep(
    title: 'Gấp các góc vào tâm',
    description: 'Gấp từng góc của hình vuông vào điểm trung tâm. Làm đều cả 4 góc.',
    imageAsset: 'assets/images/lotus_step/step-7.png',
  ),
  TutorialStep(
    title: 'Lật và gấp mặt sau',
    description: 'Lật hình qua mặt sau rồi gấp 4 góc vào tâm như bước trước.',
    imageAsset: 'assets/images/lotus_step/step-8.png',
  ),
  TutorialStep(
    title: 'Gấp tiếp các góc',
    description: 'Tiếp tục gấp 4 góc vào tâm một lần nữa để tạo hình nhỏ hơn.',
    imageAsset: 'assets/images/lotus_step/step-9.png',
  ),
  TutorialStep(
    title: 'Lật mặt và ấn tâm',
    description: 'Lật hình lại và nhẹ nhàng ấn vào tâm để các cánh bắt đầu nở ra.',
    imageAsset: 'assets/images/lotus_step/step-10.png',
  ),
  TutorialStep(
    title: 'Mở cánh ngoài',
    description: 'Kéo nhẹ 4 cánh ở tầng ngoài cùng ra để tạo hình cánh hoa đầu tiên.',
    imageAsset: 'assets/images/lotus_step/step-11.png',
  ),
  TutorialStep(
    title: 'Mở cánh giữa',
    description: 'Kéo các cánh ở tầng giữa ra, uốn nhẹ để chúng nằm giữa các cánh ngoài.',
    imageAsset: 'assets/images/lotus_step/step-12.png',
  ),
  TutorialStep(
    title: 'Mở cánh trong',
    description: 'Nhẹ nhàng kéo các cánh ở tầng trong cùng ra. Đây là phần đòi hỏi sự tỉ mỉ nhất.',
    imageAsset: 'assets/images/lotus_step/step-13.png',
  ),
  TutorialStep(
    title: 'Định hình cánh hoa',
    description: 'Uốn cong nhẹ các cánh hoa ra phía ngoài để tạo dáng tự nhiên cho hoa sen.',
    imageAsset: 'assets/images/lotus_step/step-14.png',
  ),
  TutorialStep(
    title: 'Hoàn thiện hình dạng',
    description: 'Điều chỉnh tất cả các cánh hoa để đạt được sự cân đối và thẩm mỹ.',
    imageAsset: 'assets/images/lotus_step/step-15.png',
  ),
  TutorialStep(
    title: 'Hoàn thành hoa sen',
    description: 'Hoa sen origami của bạn đã hoàn thành! Nhẹ nhàng điều chỉnh các cánh để tạo hình dáng đẹp nhất.',
    imageAsset: 'assets/images/lotus_step/step-16.png',
  ),
];

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
    tutorialSteps: kLotusSteps,
  ),
  const TutorialData(
    title: 'Hạc giấy truyền thống',
    difficulty: 'Dễ',
    difficultyColor: Color(0xFF16A34A),
    difficultyBg: Color(0xFFDCFCE7),
    rating: 4.8,
    imageUrl: 'https://picsum.photos/seed/crane-paper/600/360',
    steps: 20,
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
          color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Origami',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPurple),
        scaffoldBackgroundColor: Colors.white,
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
      },
    );
  }
}
