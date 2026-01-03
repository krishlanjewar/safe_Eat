import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:safeat/providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Theme Colors
  final Color _bgOrganic = const Color(0xFFF9FBF9);
  final Color _organicGreen = const Color(0xFF10B981);
  final Color _softBlack = const Color(0xFF1A1C1E);

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

  String _gender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _dietaryOptions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Gluten-Free',
  ];

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
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          if (response == null) {
            // No profile found - let's switch to edit mode
            setState(() {
              _profile = {};
              _isLoading = false;
              _isEditing = true; // Force edit mode to create profile
            });
          } else {
            setState(() {
              _profile = response;
              _isLoading = false;
              _populateControllers();
            });
          }
        }
      } else {
        // User is not logged in, but somehow reached this screen.
        // Let's redirect to login.
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Error: ${e.toString()}')),
        );
      }
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
    _gender = _profile!['gender'] ?? 'Male';

    final allergies = _profile!['allergies'] as List<dynamic>?;
    _allergiesController.text = allergies?.join(', ') ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final updates = {
        'id': user.id, // Ensure ID is included for upsert
        'full_name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'phone': _phoneController.text.trim(),
        'dietary_preference': _dietaryPreference,
        'gender': _gender,
        'allergies': _allergiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client.from('profiles').upsert(updates);

      // Refresh data
      await _fetchProfile();

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('profile_update_success'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('profile_error_prefix') +
                  e.toString(),
            ),
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
    final String age = userData != null
        ? userData.age.toString()
        : (_profile?['age'] ?? '0').toString();
    final double weight =
        userData?.weight ?? (_profile?['weight']?.toDouble() ?? 0.0);
    final double height =
        userData?.height ?? (_profile?['height']?.toDouble() ?? 0.0);
    final String dietary =
        userData?.dietaryPreference ??
        _profile?['dietary_preference'] ??
        'None';
    final String phone =
        userData?.phone ?? _profile?['phone'] ?? 'No phone number';

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
        backgroundColor: _bgOrganic,
        body: Center(child: CircularProgressIndicator(color: _organicGreen)),
      );
    }

    return Scaffold(
      backgroundColor: _bgOrganic,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _softBlack),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing
              ? AppLocalizations.of(context)!.translate('profile_edit_title')
              : AppLocalizations.of(context)!.translate('profile_title'),
          style: GoogleFonts.outfit(
            color: _softBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.save, color: _organicGreen),
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
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                }
              },
              tooltip: AppLocalizations.of(
                context,
              )!.translate('profile_logout_button'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Avatar + Name/Inputs)
            _buildHeader(_organicGreen, _softBlack),
            const SizedBox(height: 32),

            // 2. Health Stats Row (Weight, Height, BMI)
            _buildStatsSection(_organicGreen),
            const SizedBox(height: 32),

            // 3. Dietary Info (Dynamic)
            _buildSectionTitle(
              AppLocalizations.of(
                context,
              )!.translate('profile_section_dietary'),
            ),
            _buildDietarySection(_organicGreen, _bgOrganic),
            const SizedBox(height: 32),

            // 4. Contact Info
            _buildSectionTitle(
              AppLocalizations.of(
                context,
              )!.translate('profile_section_contact'),
            ),
            _buildContactSection(_softBlack),
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

  Widget _buildHeader(Color primary, Color text) {
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
          child: _isEditing
              ? Column(
                  children: [
                    _buildEditField(
                      _nameController,
                      AppLocalizations.of(
                        context,
                      )!.translate('profile_field_name'),
                    ),
                    const SizedBox(height: 8),
                    _buildEditField(
                      _ageController,
                      AppLocalizations.of(
                        context,
                      )!.translate('profile_field_age'),
                      type: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _genderOptions.contains(_gender)
                          ? _gender
                          : 'Male',
                      items: _genderOptions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val!),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.translate('profile_field_gender'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? 'Guest'
                          : _nameController.text,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: text,
                      ),
                    ),
                    Text(
                      '${_gender}, ${_ageController.text} ${AppLocalizations.of(context)!.translate('profile_field_age')}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: text.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
        ),
        // Text(
        //   '$_ageController.text Years',
        //   style: GoogleFonts.outfit(fontSize: 14, color: text.withOpacity(0.6)),
        // ),
      ],
    );
  }

  Widget _buildStatsSection(Color primary) {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: _buildEditField(
              _weightController,
              AppLocalizations.of(context)!.translate('profile_field_weight'),
              type: TextInputType.number,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildEditField(
              _heightController,
              AppLocalizations.of(context)!.translate('profile_field_height'),
              type: TextInputType.number,
            ),
          ),
        ],
      );
    }

    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;
    double bmi = (height > 0) ? weight / ((height / 100) * (height / 100)) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
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
            '${weight.toStringAsFixed(1)} kg',
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

  Widget _buildDietarySection(Color primary, Color bg) {
    if (_isEditing) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            value: _dietaryOptions.contains(_dietaryPreference)
                ? _dietaryPreference
                : 'None',
            items: _dietaryOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _dietaryPreference = val!),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(
                context,
              )!.translate('profile_field_dietary'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildEditField(
            _allergiesController,
            AppLocalizations.of(context)!.translate('profile_field_allergies'),
          ),
        ],
      );
    }

    final allergies = _allergiesController.text
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();

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
                    AppLocalizations.of(
                      context,
                    )!.translate('profile_field_dietary'),
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    _dietaryPreference,
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
                      AppLocalizations.of(context)!
                          .translate('profile_field_allergies')
                          .split('(')
                          .first
                          .trim(),
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
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('profile_no_allergies'),
                  style: TextStyle(color: primary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection(Color text) {
    if (_isEditing) {
      return _buildEditField(
        _phoneController,
        AppLocalizations.of(context)!.translate('profile_field_phone'),
        type: TextInputType.phone,
      );
    }
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
            _phoneController.text.isEmpty
                ? AppLocalizations.of(context)!.translate('profile_no_phone')
                : _phoneController.text,
            style: GoogleFonts.outfit(fontSize: 16, color: text),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
