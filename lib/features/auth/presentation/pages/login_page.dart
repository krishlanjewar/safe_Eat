import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login successful!')));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainLayout()),
        );
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
            content: Text('An unexpected error occurred: $e'),
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
    const Color bgCream = Color(0xFFF7F5F0);
    const Color leafGreen = Color(0xFF4A6741);
    const Color earthSand = Color(0xFFC2B280);
    const Color softBlack = Color(0xFF2D3436);
    const Color sageLight = Color(0xFF8FA88A);

    return Scaffold(
      backgroundColor: bgCream,
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
                      color: leafGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: leafGreen,
                      size: 50,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .fade(duration: 600.ms),

              const SizedBox(height: 24),

              // Title
              Text(
                    'Safe Eat',
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
                    'Eat healthy, live naturally.',
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
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: leafGreen.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: softBlack.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: leafGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: bgCream,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: softBlack.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: leafGreen,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: bgCream,
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
                              backgroundColor: leafGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                : const Text(
                                    'Login',
                                    style: TextStyle(
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

              // Toggle Sign Up / Login
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: softBlack.withOpacity(0.7)),
                    children: const [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: leafGreen,
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
}
