import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/profile/presentation/pages/profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:safeat/main.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Friend';
  bool _isLoading = true;
  String _selectedLanguage = 'English';

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (mounted) _fetchUserData();
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _userName =
                (data['full_name'] as String?)?.split(' ').first ?? 'Friend';
            _isLoading = false;
          });
          // Sync UI value with global locale if needed
          _selectedLanguage = localeNotifier.value.languageCode == 'hi'
              ? 'Hindi'
              : localeNotifier.value.languageCode == 'as'
              ? 'Asomiya'
              : 'English';
        }
      } else {
        if (mounted) {
          setState(() {
            _userName = 'Friend';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      if (mounted) {
        setState(() {
          _userName = 'Friend';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color organicGreen = Color(0xFF10B981);

    return Container(
      color: const Color(0xFFF9FBF9),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: organicGreen))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Header Section (Gradient Background)
                  _buildHeader(organicGreen, const Color(0xFF059669)),

                  // 2. Main Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Trial Banner (or Welcome Banner)
                        _buildWelcomeBanner(),

                        const SizedBox(height: 24),

                        // Top Categories
                        _buildSectionHeader(
                          AppLocalizations.of(
                            context,
                          )!.translate('home_top_categories'),
                          actionText: AppLocalizations.of(
                            context,
                          )!.translate('home_view_all'),
                        ),
                        const SizedBox(height: 16),
                        _buildCategoriesGrid(),

                        const SizedBox(height: 24),

                        // Snacky Banner (Prominent AI Feature)
                        _buildSnackyBanner(organicGreen),

                        const SizedBox(height: 24),

                        // Weekly Healthy Picks
                        _buildSectionHeader(
                          AppLocalizations.of(
                            context,
                          )!.translate('home_weekly_picks'),
                          actionText: AppLocalizations.of(
                            context,
                          )!.translate('home_shop_now'),
                        ),
                        const SizedBox(height: 16),
                        _buildHealthyPicksList(organicGreen),

                        const SizedBox(height: 24),

                        // Latest News
                        _buildSectionHeader('Latest News'),
                        const SizedBox(height: 16),
                        _buildNewsCard(organicGreen),

                        const SizedBox(height: 100), // Bottom padding
                      ],
                    ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Greeting + Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('home_greeting', {'name': _userName}),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.translate('home_tagline'),
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ],
                ),
              ),
              _buildAvatarBadge(),
            ],
          ),

          const SizedBox(height: 24),

          // Search Bar & Veg Toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => MainLayout.of(context)?.setIndex(1),
                    borderRadius: BorderRadius.circular(25),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: startColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.translate('home_search_placeholder'),
                              style: GoogleFonts.outfit(
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildLanguageSelector(),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return GestureDetector(
      onTap: () {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFD1FAE5),
          // Placeholder for user image or icon
          child: Icon(Icons.person, color: Color(0xFF10B981)),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.translate('home_lang_label'),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        PopupMenuButton<String>(
          initialValue: _selectedLanguage,
          offset: const Offset(0, 30),
          onSelected: (String value) {
            setState(() {
              _selectedLanguage = value;
            });
            // Update global locale
            if (value == 'English') {
              localeNotifier.value = const Locale('en');
            } else if (value == 'Hindi') {
              localeNotifier.value = const Locale('hi');
            } else if (value == 'Asomiya') {
              localeNotifier.value = const Locale('as');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'English',
              child: Text(
                AppLocalizations.of(context)!.translate('lang_english'),
                style: GoogleFonts.outfit(),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Hindi',
              child: Text(
                AppLocalizations.of(context)!.translate('lang_hindi'),
                style: GoogleFonts.outfit(),
              ),
            ),
            PopupMenuItem<String>(
              value: 'Asomiya',
              child: Text(
                AppLocalizations.of(context)!.translate('lang_asomiya'),
                style: GoogleFonts.outfit(),
              ),
            ),
          ],
          child: Container(
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _selectedLanguage == 'English'
                    ? 'EN'
                    : _selectedLanguage == 'Hindi'
                    ? 'HI'
                    : 'AS',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 20, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppLocalizations.of(context)!.translate('home_journey_start'),
              style: GoogleFonts.outfit(
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3436), // Soft black
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: () => MainLayout.of(context)?.setIndex(1),
            child: Text(
              actionText,
              style: GoogleFonts.outfit(
                color: const Color(0xFF10B981),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name_key': 'category_fruits',
        'icon': Icons.apple_outlined,
        'color': const Color(0xFFDCFCE7),
      },
      {
        'name_key': 'category_vegetables',
        'icon': Icons.eco_outlined,
        'color': const Color(0xFFF3E8FF),
      },
      {
        'name_key': 'category_dairy',
        'icon': Icons.egg_outlined,
        'color': const Color(0xFFFEF9C3),
      },
      {
        'name_key': 'category_grains',
        'icon': Icons.grass_outlined,
        'color': const Color(0xFFFFEDD5),
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return SizedBox(
            width: 80,
            child: InkWell(
              onTap: () => MainLayout.of(context)?.setIndex(1),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: Colors.black54,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(cat['name_key'] as String),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSnackyBanner(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('home_snacky_banner_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('home_snacky_banner_desc'),
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF4B5563),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => MainLayout.of(context)?.setIndex(4),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('home_start_now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.psychology_outlined,
            size: 60,
            color: primaryColor.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyPicksList(Color primary) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPickCard('Organic Avocados', 'Rich in healthy fats', primary),
          const SizedBox(width: 16),
          _buildPickCard('Almond Milk', 'Dairy-free goodness', primary),
          const SizedBox(width: 16),
          _buildPickCard('Quinoa Pack', 'High protein grain', primary),
        ],
      ),
    );
  }

  Widget _buildPickCard(String title, String subtitle, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.local_florist_outlined, color: color),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.article, color: primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top 10 Superfoods for 2025',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Discover the nutrient powerhouses taking over the market.',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
