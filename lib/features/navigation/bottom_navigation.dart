import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/home/presentation/pages/home_screen.dart';
import 'package:safeat/features/search/presentation/pages/search_screen.dart';
import 'package:safeat/features/chatbot/presentation/pages/chat_screen.dart';
import 'package:safeat/features/pre_shopping/presentation/pages/pre_shopping_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const Center(child: Text("Scan Screen Placeholder")),
    const PreShoppingScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF7B1FA2), // Purple 700 to match button
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Pre Shopping',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              label: 'Snacky',
            ),
          ],
        ),
      ),
    );
  }
}
