import 'package:flutter/material.dart';
import '../main.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _step = 0;
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as TutorialData?
        ?? kFeaturedTutorials.first;
    final steps = data.tutorialSteps;

    if (_done || steps.isEmpty) {
      return _CompletionView(
        onHome: () => Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
      );
    }

    final total = steps.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _Header(
            step: _step,
            total: total,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            flex: 5,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF8F8F8),
              child: Image.asset(
                steps[_step].imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 64,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ),
            ),
          ),
          _StepCard(
            step: steps[_step],
            stepIndex: _step,
            total: total,
            onPrev: _step > 0 ? () => setState(() => _step--) : null,
            onNext: () {
              if (_step < total - 1) {
                setState(() => _step++);
              } else {
                setState(() => _done = true);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Header with progress bar ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.total,
    required this.onBack,
  });

  final int step;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: kSplashGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Bước ${step + 1} / $total',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (step + 1) / total,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step info card ───────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.stepIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  final TutorialStep step;
  final int stepIndex;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  static List<Widget> _buildDots(int total, int active) {
    const maxVisible = 9;
    final start = total > maxVisible
        ? (active - maxVisible ~/ 2).clamp(0, total - maxVisible)
        : 0;
    final count = total > maxVisible ? maxVisible : total;

    return List.generate(count, (i) {
      final isActive = start + i == active;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: isActive ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? kPurple : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildDots(total, stepIndex),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.chevron_left, size: 20),
                  label: const Text('Trước'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    foregroundColor: const Color(0xFF6B7280),
                    disabledForegroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: kBtnGradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stepIndex == total - 1 ? 'Hoàn thành' : 'Tiếp theo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Completion screen ────────────────────────────────────────────────────────

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFCF0FF),
                  Color(0xFFFFF0F8),
                  Color(0xFFF0F4FF),
                ],
              ),
            ),
          ),
          const _Confetti(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Tuyệt vời!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn đã hoàn thành mẫu Origami\nnày! Hãy tiếp tục khám phá thêm\ncác mẫu khác nhé.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    GradientButton(
                      label: '  Về trang chủ',
                      onPressed: onHome,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Chia sẻ thành tích'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          foregroundColor: const Color(0xFF374151),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tiếp tục khám phá thêm các mẫu Origami\ntuyệt đẹp khác!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confetti decoration ──────────────────────────────────────────────────────

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.dx,
    required this.dy,
    required this.color,
    required this.angle,
  });

  final double dx;
  final double dy;
  final Color color;
  final double angle;
}

class _Confetti extends StatelessWidget {
  const _Confetti();

  static const _pieces = [
    _ConfettiPiece(dx: 0.05, dy: 0.08, color: Color(0xFFE879F9), angle: 0.5),
    _ConfettiPiece(dx: 0.15, dy: 0.14, color: Color(0xFF818CF8), angle: -0.8),
    _ConfettiPiece(dx: 0.25, dy: 0.06, color: Color(0xFFF472B6), angle: 1.2),
    _ConfettiPiece(dx: 0.88, dy: 0.09, color: Color(0xFF34D399), angle: -0.4),
    _ConfettiPiece(dx: 0.78, dy: 0.15, color: Color(0xFFFBBF24), angle: 0.9),
    _ConfettiPiece(dx: 0.93, dy: 0.20, color: Color(0xFF60A5FA), angle: -1.1),
    _ConfettiPiece(dx: 0.08, dy: 0.22, color: Color(0xFFFBBF24), angle: 0.3),
    _ConfettiPiece(dx: 0.72, dy: 0.07, color: Color(0xFFE879F9), angle: 1.5),
    _ConfettiPiece(dx: 0.35, dy: 0.03, color: Color(0xFF818CF8), angle: -0.6),
    _ConfettiPiece(dx: 0.60, dy: 0.10, color: Color(0xFFF472B6), angle: 0.7),
    _ConfettiPiece(dx: 0.47, dy: 0.18, color: Color(0xFF34D399), angle: -1.3),
    _ConfettiPiece(dx: 0.10, dy: 0.85, color: Color(0xFF60A5FA), angle: 0.4),
    _ConfettiPiece(dx: 0.80, dy: 0.80, color: Color(0xFFE879F9), angle: -0.9),
    _ConfettiPiece(dx: 0.90, dy: 0.90, color: Color(0xFFFBBF24), angle: 1.1),
    _ConfettiPiece(dx: 0.20, dy: 0.90, color: Color(0xFF818CF8), angle: -0.2),
    _ConfettiPiece(dx: 0.55, dy: 0.88, color: Color(0xFFF472B6), angle: 0.8),
    _ConfettiPiece(dx: 0.03, dy: 0.50, color: Color(0xFF34D399), angle: -0.7),
    _ConfettiPiece(dx: 0.97, dy: 0.45, color: Color(0xFF60A5FA), angle: 1.3),
    _ConfettiPiece(dx: 0.43, dy: 0.93, color: Color(0xFFE879F9), angle: -0.5),
    _ConfettiPiece(dx: 0.67, dy: 0.95, color: Color(0xFFFBBF24), angle: 0.6),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: _pieces
              .map(
                (p) => Positioned(
                  left: constraints.maxWidth * p.dx,
                  top: constraints.maxHeight * p.dy,
                  child: Transform.rotate(
                    angle: p.angle,
                    child: Container(
                      width: 9,
                      height: 15,
                      decoration: BoxDecoration(
                        color: p.color.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
