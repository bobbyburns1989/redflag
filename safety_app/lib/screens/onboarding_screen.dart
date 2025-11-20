import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.security,
      title: 'Welcome to Pink Flag',
      description:
          'Stay Safe, Stay Aware. A tool to help you check public sex offender registries by name. This app is designed for personal safety awareness.',
      color: AppColors.primaryPink,
    ),
    OnboardingPage(
      icon: Icons.gavel,
      title: 'Important Legal Notice',
      description:
          'This information comes from public registries ONLY. Data may be incomplete, outdated, or contain errors. Always verify independently.',
      color: AppColors.deepPink,
    ),
    OnboardingPage(
      icon: Icons.warning_amber,
      title: 'Ethical Use Only',
      description:
          'This app is for awareness, NOT for harassment, vigilante action, or discrimination. Misuse is illegal and harmful.',
      color: AppColors.rose,
    ),
    OnboardingPage(
      icon: Icons.privacy_tip,
      title: 'Your Privacy Matters',
      description:
          'Searches are completely private and NOT saved. We only collect your email for authentication and track search credits. No search history. No location tracking. No profile building.',
      color: AppColors.primaryPink,
    ),
    OnboardingPage(
      icon: Icons.verified_user,
      title: 'False Positives',
      description:
          'Name matches may NOT be the same person. Common names can have multiple matches. Always verify through official channels.',
      color: AppColors.deepPink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: AppSpacing.screenPaddingAll,
              child: Column(
                children: [
                  // Enhanced page indicator with animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: _currentPage == index
                              ? AppColors.pinkGradient
                              : null,
                          color: _currentPage == index
                              ? null
                              : AppColors.lightPink,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: _currentPage == index
                              ? AppColors.softPinkShadow
                              : [],
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.verticalSpaceMd,
                  // Navigation buttons - balanced layout
                  Row(
                    children: [
                      // Back button - equal width with Next
                      Expanded(
                        child: _currentPage > 0
                            ? CustomButton(
                                text: 'Back',
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                                variant: ButtonVariant.secondary,
                                size: ButtonSize.large,
                                icon: Icons.arrow_back,
                              )
                            : const SizedBox.shrink(),
                      ),
                      // Small gap between buttons
                      if (_currentPage > 0) const SizedBox(width: 12),
                      // Next/Get Started button - equal width with Back
                      Expanded(
                        child: CustomButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _nextPage,
                          variant: ButtonVariant.primary,
                          size: ButtonSize.large,
                          icon: _currentPage == _pages.length - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward,
                          iconRight: true,
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

  Widget _buildPage(OnboardingPage page) {
    final int pageIndex = _pages.indexOf(page);
    final double parallaxOffset = (_pageOffset - pageIndex).abs();
    final double parallaxScale = 1.0 - (parallaxOffset * 0.3).clamp(0.0, 0.3);
    final double parallaxOpacity = (1.0 - parallaxOffset).clamp(0.0, 1.0);

    return Padding(
      padding: AppSpacing.screenPaddingAll,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with parallax effect
          Transform.scale(
            scale: parallaxScale,
            child: Opacity(
              opacity: parallaxOpacity,
              child:
                  Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              page.color.withValues(alpha: 0.2),
                              page.color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: page.color.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(page.icon, size: 100, color: page.color),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.elasticOut,
                      )
                      .then()
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
            ),
          ),
          AppSpacing.verticalSpaceXl,

          // Title with slide animation
          Transform.translate(
            offset: Offset(0, parallaxOffset * 20),
            child: Opacity(
              opacity: parallaxOpacity,
              child:
                  Text(
                        page.title,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: page.color,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(begin: 0.3, end: 0),
            ),
          ),
          AppSpacing.verticalSpaceMd,

          // Description with fade and slide
          Transform.translate(
            offset: Offset(0, parallaxOffset * 30),
            child: Opacity(
              opacity: parallaxOpacity,
              child:
                  Text(
                        page.description,
                        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.5, end: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
