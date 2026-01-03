import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF10B981); // organic green

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.bounceOut)
                .fadeIn(),

            const SizedBox(height: 24),

            // App Name
            Text(
                  "Safe Eat",
                  style: GoogleFonts.outfit(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                    letterSpacing: 1.2,
                  ),
                )
                .animate()
                .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 400.ms)
                .fadeIn(),

            const SizedBox(height: 8),

            // Tagline
            Text(
                  "Eat healthy, live naturally.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                )
                .animate()
                .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 600.ms)
                .fadeIn(),

            const SizedBox(height: 60),

            // Loading Indicator
            const CircularProgressIndicator(
              color: primaryColor,
              strokeWidth: 3,
            ).animate().fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}
