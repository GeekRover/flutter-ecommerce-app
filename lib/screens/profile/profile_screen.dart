import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (!authProvider.isLoggedIn) {
      return _buildNotLoggedIn(context);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: authProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        // Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          child: Text(
                            authProvider.user!.name.isNotEmpty
                                ? authProvider.user!.name[0].toUpperCase()
                                : '',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // User Name
                        Text(
                          authProvider.user!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // User Email
                        Text(
                          authProvider.user!.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Edit Profile Button
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile Options
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Options List
                  _buildOptionItem(
                    context,
                    Icons.shopping_bag,
                    'My Orders',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildOptionItem(
                    context,
                    Icons.favorite,
                    'My Wishlist',
                    () {
                      // Navigate to wishlist screen
                      // Implement navigation to wishlist screen here
                    },
                  ),
                  _buildOptionItem(
                    context,
                    Icons.location_on,
                    'Shipping Addresses',
                    () {
                      // Navigate to addresses screen
                      // Implement navigation to addresses screen here
                    },
                  ),
                  _buildOptionItem(
                    context,
                    Icons.help,
                    'Help & Support',
                    () {
                      // Navigate to help screen
                      // Implement navigation to help screen here
                    },
                  ),
                  _buildOptionItem(
                    context,
                    Icons.logout,
                    'Logout',
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                authProvider.signOut();
                                Navigator.pop(context);
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    textColor: Colors.red,
                    iconColor: Colors.red,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'You are not logged in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please login to access your profile',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}