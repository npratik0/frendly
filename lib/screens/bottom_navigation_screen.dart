import 'package:flutter/material.dart';
import 'package:frendly/screens/bottom_screen/chat_screen.dart';
import 'package:frendly/screens/bottom_screen/create_post_screen.dart';
import 'package:frendly/screens/bottom_screen/home_screen.dart';
import 'package:frendly/screens/bottom_screen/profile_screen.dart';
import 'package:frendly/screens/bottom_screen/search_screen.dart';
import 'package:frendly/theme/app_styles.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> lstBottomScreen = const [
    HomeScreen(),
    SearchScreen(),
    CreatePostScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // to remove back arrow
        title: const Text("Frendly", style: AppStyles.logoTitle),
      ),
      endDrawer: SafeArea(
        child: Drawer(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
            children: [
              //  USER HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 36, color: Colors.blue),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Pratik Neupane",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "@pratik.dev",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              //  DRAWER ITEMS
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blue),
                title: const Text("My Profile"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border, color: Colors.blue),
                title: const Text("Saved"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined, color: Colors.blue),
                title: const Text("Friends"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.blue,
                ),
                title: const Text("Activity"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(
                  Icons.settings_outlined,
                  color: Colors.blue,
                ),
                title: const Text("Settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {},
              ),

              const Spacer(),

              //  LOGOUT
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                  // logout logic
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),

      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey.shade700,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 35),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
            label: 'Post',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 35),
            label: "Chat",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 35),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
