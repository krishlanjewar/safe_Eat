import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/navigation/bottom_navigation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_service.dart';

// Global locale controller
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // Load saved locale
  final savedLocale = await LocaleService.getLocale();
  localeNotifier.value = savedLocale;

  // Listen for locale changes and save them
  localeNotifier.addListener(() {
    LocaleService.saveLocale(localeNotifier.value);
  });

  runApp(
    ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return MyApp(home: const MainLayout(), locale: locale);
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget home;
  final Locale locale;
  const MyApp({super.key, required this.home, required this.locale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Eat',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('as', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald Green
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF059669),
          surface: const Color(0xFFF9FBF9),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF9FBF9,
        ), // Soft organic off-white
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme)
            .copyWith(
              displayLarge: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1E),
              ),
              titleLarge: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1C1E),
              ),
              bodyLarge: GoogleFonts.outfit(color: const Color(0xFF2D3135)),
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.black.withOpacity(0.04), width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: home,
    );
  }
}
