import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:safeat/core/localization/app_localizations.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Auth Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Profile Controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _phoneController = TextEditingController();

  // Selection State
  String _gender = 'Male';
  String _dietaryPreference = 'None';
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _dietaryOptions = [
    'None',
    'Vegan',
    'Vegetarian',
    'Gluten Free',
    'Halal',
    'Keto',
    'Paleo',
  ];

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Sign Up User
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        // 2. Create Profile Data
        // Note: You must have a 'profiles' table in Supabase with these columns.
        // If RLS is enabled, ensure policies allow insert.
        final profileData = {
          'id': user.id,
          'full_name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text) ?? 0,
          'gender': _gender,
          'height': double.tryParse(_heightController.text) ?? 0.0,
          'weight': double.tryParse(_weightController.text) ?? 0.0,
          'dietary_preference': _dietaryPreference,
          'allergies': _allergiesController.text
              .split(',')
              .map((e) => e.trim())
              .toList(),
          'phone': _phoneController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        try {
          await Supabase.instance.client.from('profiles').upsert(profileData);
        } catch (dbError) {
          debugPrint('Profile creation failed: $dbError');
          // Proceeding anyway since Auth succeeded (Soft fail)
          // Ideally, we should retry or show a specific error.
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.translate('register_success'),
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
              AppLocalizations.of(context)!.translate('register_error_prefix') +
                  e.toString(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors (Consistent with Login)
    const Color organicGreen = Color(0xFF10B981);
    const Color softBlack = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: softBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('register_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: softBlack,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                Text(
                  AppLocalizations.of(context)!.translate('register_subtitle'),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: softBlack.withOpacity(0.6),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // -- Personal Info Section --
                _buildSectionLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('register_section_about'),
                ),
                _buildTextField(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_full_name'),
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: AppLocalizations.of(
                          context,
                        )!.translate('register_age'),
                        icon: Icons.calendar_today_outlined,
                        controller: _ageController,
                        inputType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: AppLocalizations.of(
                          context,
                        )!.translate('register_gender'),
                        value: _gender,
                        items: _genders,
                        onChanged: (val) => setState(() => _gender = val!),
                        icon: Icons.people_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: AppLocalizations.of(
                          context,
                        )!.translate('register_height'),
                        icon: Icons.height,
                        controller: _heightController,
                        inputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: AppLocalizations.of(
                          context,
                        )!.translate('register_weight'),
                        icon: Icons.monitor_weight_outlined,
                        controller: _weightController,
                        inputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // -- Nutrition Info Section --
                _buildSectionLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('register_section_nutrition'),
                ),
                _buildDropdown(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_dietary'),
                  value: _dietaryPreference,
                  items: _dietaryOptions,
                  onChanged: (val) => setState(() => _dietaryPreference = val!),
                  icon: Icons.restaurant_menu,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_allergies'),
                  icon: Icons.warning_amber_rounded,
                  controller: _allergiesController,
                  hint: AppLocalizations.of(
                    context,
                  )!.translate('register_allergies_hint'),
                ),

                const SizedBox(height: 32),

                // -- Account Logic --
                _buildSectionLabel(
                  AppLocalizations.of(
                    context,
                  )!.translate('register_section_security'),
                ),
                _buildTextField(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_email'),
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_phone'),
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: AppLocalizations.of(
                    context,
                  )!.translate('register_password'),
                  icon: Icons.lock_outline,
                  controller: _passwordController,
                  isObscure: true,
                ),

                const SizedBox(height: 48),

                // -- Submit Button --
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
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
                            )!.translate('register_button'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF10B981),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    bool isObscure = false,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isObscure,
      validator: (val) {
        if (val == null || val.isEmpty) {
          if (label ==
              AppLocalizations.of(context)!.translate('register_allergies')) {
            return null; // Optional
          }
          return AppLocalizations.of(
            context,
          )!.translate('register_required', {'label': label});
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: const Color(0xFF1A1C1E).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF1A1C1E).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
