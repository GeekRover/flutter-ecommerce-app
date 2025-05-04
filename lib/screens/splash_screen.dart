import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay to show splash screen
    Future.delayed(const Duration(seconds: 2), () {
      checkAuth();
    });
  }

  void checkAuth() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Navigate based on authentication state
    if (authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Icon(
              Icons.shopping_bag,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            // App name
            Text(
              'E-Commerce App',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}