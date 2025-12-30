import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/profile/presentation/pages/profile_screen.dart';
import 'features/main_layout/main_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Eat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald Green
          primary: const Color(0xFF10B981),
          // We can define other custom colors here to match the spec precisely
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor:
              Colors.transparent, // Removes the slight primary tint in M3
        ),
      ),
      home: const MainLayout(),
    );
  }
}
