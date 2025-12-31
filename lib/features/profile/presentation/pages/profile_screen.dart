import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:safeat/providers/user_provider.dart';
import 'package:safeat/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Theme Colors
  final Color _bgCream = const Color(0xFFF7F5F0);
  final Color _leafGreen = const Color(0xFF4A6741);
  final Color _sageSoft = const Color(0xFF8FA88A);
  final Color _softBlack = const Color(0xFF2D3436);

  bool _isLoading = true;
  bool _isEditing = false; // Toggle for Edit Mode

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();

  String _dietaryPreference = 'None';

  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _profile = data;
            _isLoading = false;
            _populateControllers();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateControllers() {
    if (_profile == null) return;
    _nameController.text = _profile!['full_name'] ?? '';
    _ageController.text = (_profile!['age'] ?? '').toString();
    _weightController.text = (_profile!['weight'] ?? '').toString();
    _heightController.text = (_profile!['height'] ?? '').toString();
    _phoneController.text = _profile!['phone'] ?? '';
    _dietaryPreference = _profile!['dietary_preference'] ?? 'None';

    final allergies = _profile!['allergies'] as List<dynamic>?;
    _allergiesController.text = allergies?.join(', ') ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final updates = {
        'full_name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'phone': _phoneController.text.trim(),
        'dietary_preference': _dietaryPreference,
        'allergies': _allergiesController.text
            .split(',')
            .map((e) => e.trim())
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);

      // Refresh data
      await _fetchProfile();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get user from Provider
    final userData = context.watch<UserProvider>().user;

    // 2. Logic to handle "local/demo data" or "backend data"
    // If we have data from signup (Provider), use it.
    // Otherwise fallback to what we fetched from Supabase (if any).
    final String name = userData?.name ?? _profile?['full_name'] ?? 'Guest';
    final String age = userData != null ? userData.age.toString() : (_profile?['age'] ?? '0').toString();
    final double weight = userData?.weight ?? (_profile?['weight']?.toDouble() ?? 0.0);
    final double height = userData?.height ?? (_profile?['height']?.toDouble() ?? 0.0);
    final String dietary = userData?.dietaryPreference ?? _profile?['dietary_preference'] ?? 'None';
    final String phone = userData?.phone ?? _profile?['phone'] ?? 'No phone number';
    
    // Allergies logic
    List<String> allergies = [];
    if (userData != null) {
      allergies = userData.allergies;
    } else if (_profile != null && _profile!['allergies'] != null) {
      allergies = List<String>.from(_profile!['allergies']);
    }

    // BMI logic
    double bmi = 0;
    if (userData != null) {
      bmi = userData.bmi;
    } else if (height > 0) {
      bmi = weight / ((height / 100) * (height / 100));
    }

    if (_isLoading && _profile == null && userData == null) {
      return Scaffold(
        backgroundColor: _bgCream,
        body: Center(child: CircularProgressIndicator(color: _leafGreen)),
      );
    }

    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _softBlack),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Profile' : 'My Safety Profile',
          style: GoogleFonts.outfit(
            color: _softBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save, color: _leafGreen),
              onPressed: _saveProfile,
            )
          else
            IconButton(
              icon: Icon(Icons.edit_outlined, color: _softBlack),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red[300]),
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                LoginPage();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Avatar + Name/Inputs)
            _buildHeader(_leafGreen, _softBlack, name, age),
            const SizedBox(height: 32),

            // 2. Health Stats Row (Weight, Height, BMI)
            _buildStatsSection(_leafGreen, _sageSoft, weight, height, bmi),
            const SizedBox(height: 32),

            // 3. Dietary Info (Dynamic)
            _buildSectionTitle('Dietary Configuration'),
            _buildDietarySection(_leafGreen, _bgCream, dietary, allergies),
            const SizedBox(height: 32),

            // 4. Contact Info
            _buildSectionTitle('Contact Details'),
            _buildContactSection(_softBlack, phone),
            const SizedBox(height: 32),
          ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _softBlack,
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color text, String name, String age) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.1),
            border: Border.all(color: primary, width: 2),
            image: const DecorationImage(
              image: NetworkImage(
                "https://placehold.co/100x100/png",
              ), // Placeholder
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              Text(
                '$age Years',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: text.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Refactor stats section to accept data instead of using controllers
  Widget _buildStatsSection(Color primary, Color secondary, double weight, double height, double bmi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Weight',
            '$weight kg',
            Icons.monitor_weight_outlined,
            primary,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(
            'Height',
            '${height.toStringAsFixed(0)} cm',
            Icons.height,
            primary,
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(
            'BMI',
            bmi.toStringAsFixed(1),
            Icons.assessment_outlined,
            primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _softBlack,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: _softBlack.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDietarySection(Color primary, Color bg, String dietaryPreference, List<String> allergies) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.restaurant, color: primary),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dietary Preference',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    dietaryPreference,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _softBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (allergies.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Allergies',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergies
                      .map(
                        (a) => Chip(
                          label: Text(a.trim()),
                          backgroundColor: Colors.white,
                          labelStyle: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 12,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: primary),
                const SizedBox(width: 12),
                Text('No known allergies.', style: TextStyle(color: primary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(Color text, String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_iphone_rounded, color: Colors.grey),
          const SizedBox(width: 16),
          Text(
            phoneNumber,
            style: GoogleFonts.outfit(fontSize: 16, color: text),
          ),
        ],
      ),
    );
  }

}
