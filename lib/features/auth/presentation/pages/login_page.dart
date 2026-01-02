import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/main.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Login Logic
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate or show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('auth_success'),
            ),
          ),
        );

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.translate('auth_error', {'error': e.toString()}),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Organic, Natural Theme Colors
    const Color organicGreen = Color(0xFF10B981);
    const Color softBlack = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [_buildLanguageSelector(organicGreen)],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon / Logo Area
              Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: organicGreen.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: organicGreen,
                      size: 50,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fade(duration: 600.ms),

              const SizedBox(height: 24),

              // Title
              Text(
                    AppLocalizations.of(context)!.translate('login_title'),
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: softBlack,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.3, end: 0),

              Text(
                    AppLocalizations.of(context)!.translate('login_subtitle'),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: softBlack.withOpacity(0.6),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 300.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 48),

              // Form Fields
              Container(
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.translate('login_email_hint'),
                            labelStyle: TextStyle(
                              color: softBlack.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: organicGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FBF9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(
                              context,
                            )!.translate('login_password_hint'),
                            labelStyle: TextStyle(
                              color: softBlack.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: organicGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FBF9),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: organicGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.translate('login_button'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              TextButton(
                onPressed: () async {
                  final registered = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                  if (registered == true && mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(
                      context,
                    )!.translate('login_no_account'),
                    style: TextStyle(color: softBlack.withOpacity(0.7)),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        )!.translate('login_sign_up'),
                        style: const TextStyle(
                          color: organicGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(Color organicGreen) {
    String currentLang = localeNotifier.value.languageCode == 'hi'
        ? 'HI'
        : localeNotifier.value.languageCode == 'as'
        ? 'AS'
        : 'EN';

    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          if (value == 'EN') {
            localeNotifier.value = const Locale('en');
          } else if (value == 'HI') {
            localeNotifier.value = const Locale('hi');
          } else if (value == 'AS') {
            localeNotifier.value = const Locale('as');
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'EN', child: Text('English')),
          const PopupMenuItem(value: 'HI', child: Text('Hindi')),
          const PopupMenuItem(value: 'AS', child: Text('Asomiya')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: organicGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language, size: 16, color: organicGreen),
              const SizedBox(width: 4),
              Text(
                currentLang,
                style: TextStyle(
                  color: organicGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
