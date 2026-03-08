import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/hive_constants.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF9FAFB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              // Container(
              //   padding: const EdgeInsets.all(24),
              //   decoration: BoxDecoration(
              //     gradient: AppConstants.primaryGradient,
              //     borderRadius: const BorderRadius.only(
              //       bottomLeft: Radius.circular(24),
              //       bottomRight: Radius.circular(24),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       Container(
              //         width: 80,
              //         height: 80,
              //         decoration: BoxDecoration(
              //           shape: BoxShape.circle,
              //           border: Border.all(color: Colors.white, width: 3),
              //           image: const DecorationImage(
              //             image: NetworkImage(
              //               AppConstants.defaultProfilePicture,
              //             ),
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              //       ),
              //       const SizedBox(height: 16),
              //       const Text(
              //         'John Doe',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       const Text(
              //         '@johndoe',
              //         style: TextStyle(color: Colors.white70, fontSize: 14),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 8),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'My Profile',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to profile
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.bookmark_border,
                      title: 'Saved Posts',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to saved posts
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to edit profile
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to change password
                      },
                    ),
                    const Divider(height: 32, thickness: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // App Version
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppConstants.primaryBlue, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear auth data
              final authBox = await Hive.openBox(HiveConstants.authBox);
              await authBox.clear();

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer

                // Navigate to login screen
                // Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 30),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'A beautiful social media app built with Flutter following Clean Architecture principles.',
        ),
      ],
    );
  }
}
