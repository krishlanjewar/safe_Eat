import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/features/home/presentation/pages/home_screen.dart';
import 'package:safeat/features/chatbot/presentation/pages/chat_screen.dart';
import 'package:safeat/features/search/presentation/pages/search_screen.dart';
import 'package:safeat/features/scan/presentation/pages/scan_screen.dart';
import 'package:safeat/features/pre_shopping/presentation/pages/pre_shopping_screen.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  static _MainLayoutState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainLayoutState>();

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void setIndex(int index) async {
    if (!mounted) return;

    // Check auth for restricted tabs (Pantry = 3, Chat = 4)
    final user = Supabase.instance.client.auth.currentUser;
    if ((index == 3 || index == 4) && user == null) {
      final loggedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      if (loggedIn == true && mounted) {
        setState(() {
          _currentIndex = index;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ScanScreen(),
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) async {
            // Check auth for restricted tabs (Pantry = 3, Chat = 4)
            final user = Supabase.instance.client.auth.currentUser;
            if ((index == 3 || index == 4) && user == null) {
              final loggedIn = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );

              if (loggedIn == true && mounted) {
                setState(() => _currentIndex = index);
              }
              return;
            }
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF10B981), // Emerald Green
          unselectedItemColor: const Color(0xFF9CA3AF),
          selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: AppLocalizations.of(context)!.translate('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded),
              activeIcon: const Icon(Icons.search_rounded),
              label: AppLocalizations.of(context)!.translate('nav_search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              activeIcon: const Icon(Icons.qr_code_scanner_rounded),
              label: AppLocalizations.of(context)!.translate('nav_scan'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_basket_outlined),
              activeIcon: const Icon(Icons.shopping_basket_rounded),
              label: AppLocalizations.of(
                context,
              )!.translate('nav_pre_shopping'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_outlined),
              activeIcon: const Icon(Icons.auto_awesome_rounded),
              label: AppLocalizations.of(context)!.translate('nav_chat'),
            ),
          ],
        ),
      ),
    );
  }
}
