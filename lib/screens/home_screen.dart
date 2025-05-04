import 'package:ecommerce_app/screens/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'product/products_screen.dart';
import 'product/featured_products_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_dashboard.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Check if user is logged in
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }
    
    // Admin dashboard
    if (authProvider.isAdmin) {
      return const AdminDashboard();
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
          children: [
            const FeaturedProductsScreen(),
            const ProductsScreen(),
            const CartScreen(),
            const ProfileScreen(),
          ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}