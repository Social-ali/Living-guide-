import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';

import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/features/products_screen.dart';
import 'screens/features/recipes_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LivingGuideApp());
}

class LivingGuideApp extends StatelessWidget {
  const LivingGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Living Guide",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, show main app
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // If not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;

    // Listen for authentication changes
    _authService.authStateChanges.listen((User? user) {
      if (mounted) {
        setState(() {
          final wasAuthenticated = _currentUser != null;
          final isAuthenticated = user != null;

          _currentUser = user;

          // If user logged out and was on profile screen, navigate to home
          if (wasAuthenticated &&
              !isAuthenticated &&
              _selectedIndex == _screens.length - 1) {
            _selectedIndex = 0; // Navigate to home
          }
        });
      }
    });
  }

  // Get screens list based on authentication status
  List<Widget> get _screens {
    final baseScreens = [
      const HomeScreen(),
      const DashboardScreen(),
      const GalleryScreen(),
      const AboutScreen(),
      const ContactScreen(),
      const ProductsScreen(),
      const RecipesScreen(),
    ];

    // Add Profile screen only if user is authenticated
    if (_currentUser != null) {
      baseScreens.add(const ProfileScreen());
    }

    return baseScreens;
  }

  // Get navigation items based on authentication status
  List<BottomNavigationBarItem> get _navigationItems {
    final baseItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        label: "Dashboard",
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Gallery"),
      const BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
      const BottomNavigationBarItem(
        icon: Icon(Icons.contact_mail),
        label: "Contact",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag),
        label: "Products",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu),
        label: "Recipes",
      ),
    ];

    // Add Profile navigation item only if user is authenticated
    if (_currentUser != null) {
      baseItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      );
    }

    return baseItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Ensure index is within bounds
          if (index < _screens.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: _navigationItems,
      ),
    );
  }
}
