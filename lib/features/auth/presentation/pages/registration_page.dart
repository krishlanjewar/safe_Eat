import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:safeat/models/user_model.dart';
import 'package:safeat/providers/user_provider.dart';

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
        }

        // 3. Update Local State (Provider) - Added for dynamic profile
        if (mounted) {
          final userModel = UserModel(
            name: _nameController.text.trim(),
            age: int.tryParse(_ageController.text) ?? 0,
            weight: double.tryParse(_weightController.text) ?? 0.0,
            height: double.tryParse(_heightController.text) ?? 0.0,
            dietaryPreference: _dietaryPreference,
            allergies: _allergiesController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            phone: _phoneController.text.trim(),
          );

          Provider.of<UserProvider>(context, listen: false).setUser(userModel);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
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
            content: Text('Error: $e'),
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
    const Color bgCream = Color(0xFFF7F5F0);
    const Color leafGreen = Color(0xFF4A6741);
    const Color softBlack = Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: bgCream,
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
                  'Join Safe Eat',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: softBlack,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                Text(
                  'Let’s get to know your nutrition needs.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: softBlack.withOpacity(0.6),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // -- Personal Info Section --
                _buildSectionLabel('About You'),
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Age',
                        icon: Icons.calendar_today_outlined,
                        controller: _ageController,
                        inputType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Gender',
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
                        label: 'Height (cm)',
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
                        label: 'Weight (kg)',
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
                _buildSectionLabel('Nutrition & Health'),
                _buildDropdown(
                  label: 'Dietary Preference',
                  value: _dietaryPreference,
                  items: _dietaryOptions,
                  onChanged: (val) => setState(() => _dietaryPreference = val!),
                  icon: Icons.restaurant_menu,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Allergies (comma separated)',
                  icon: Icons.warning_amber_rounded,
                  controller: _allergiesController,
                  hint: 'e.g. Peanuts, Shellfish',
                ),

                const SizedBox(height: 32),

                // -- Account Logic --
                _buildSectionLabel('Account Security'),
                _buildTextField(
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  controller: _phoneController,
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Password',
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
                            'Create Account',
                            style: TextStyle(
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
          color: const Color(0xFF8FA88A), // Sage Light
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
          if (label == 'Allergies (comma separated)') return null; // Optional
          return '$label is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: const Color(0xFF2D3436).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6741)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
        labelStyle: TextStyle(color: const Color(0xFF2D3436).withOpacity(0.5)),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6741)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
