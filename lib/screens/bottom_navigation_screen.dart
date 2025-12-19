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

  List<Widget> lstBottomScreen = [
    const HomeScreen(),
    const SearchScreen(),
    const CreatePostScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Frendly", style: AppStyles.logoTitle,
      )),
      body: lstBottomScreen[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[450],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 35),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 35),
            label: 'Search',
          ),
          // BottomNavigationBarItem(icon: Icon(Icons.add, size: 30), label: ''),
          BottomNavigationBarItem(
            icon: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 30),
            ),
            label: 'Post',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 35),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 35),
            label: "Profile",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
