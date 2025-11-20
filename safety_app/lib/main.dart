import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/search_screen.dart';
import 'screens/resources_screen.dart';
import 'screens/store_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/image_search_screen.dart';
import 'widgets/page_transitions.dart';
import 'widgets/custom_bottom_nav.dart';
import 'theme/app_theme.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qjbtmrbbjivniveptdjl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqYnRtcmJiaml2bml2ZXB0ZGpsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0Mzk4NDMsImV4cCI6MjA3ODAxNTg0M30.xltmKOa23l0KBSrDGOCQ8xJ7jQbxRxzeBjgJ_NtbH0I',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  if (kDebugMode) {
    print('✅ [MAIN] Supabase initialized');
  }

  // Print app configuration
  AppConfig.printConfig();

  // Listen to auth state changes for debugging
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (kDebugMode) {
      print('🔐 [MAIN] Auth state changed: ${data.event}');
      print('🔐 [MAIN] Session user: ${data.session?.user.id}');
      print('🔐 [MAIN] Current user: ${Supabase.instance.client.auth.currentUser?.id}');
    }
  });

  runApp(const PinkFlagApp());
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;

class PinkFlagApp extends StatelessWidget {
  const PinkFlagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pink Flag',
      theme: AppTheme.lightTheme,
      // Start with splash screen
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Custom transitions for different routes
        switch (settings.name) {
          case '/':
            return PageTransitions.fadeTransition(const SplashScreen());
          case '/onboarding':
            return PageTransitions.slideAndFade(const OnboardingScreen());
          case '/login':
            return PageTransitions.slideAndFade(const LoginScreen());
          case '/signup':
            return PageTransitions.slideAndFade(const SignUpScreen());
          case '/home':
            return PageTransitions.fadeTransition(const HomeScreen());
          case '/search':
            return PageTransitions.slideFromRight(const SearchScreen());
          case '/resources':
            return PageTransitions.slideFromBottom(const ResourcesScreen());
          case '/store':
            return PageTransitions.slideFromBottom(const StoreScreen());
          case '/settings':
            return PageTransitions.slideFromRight(const SettingsScreen());
          case '/image-search':
            return PageTransitions.slideFromBottom(const ImageSearchScreen());
          default:
            return PageTransitions.fadeTransition(const SplashScreen());
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  final List<Widget> _screens = [
    const SearchScreen(),
    const ResourcesScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitions.tabTransition(
        currentIndex: _currentIndex,
        previousIndex: _previousIndex,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          CustomBottomNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
          ),
          CustomBottomNavItem(
            icon: Icons.emergency_outlined,
            activeIcon: Icons.emergency,
            label: 'Resources',
          ),
          CustomBottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
