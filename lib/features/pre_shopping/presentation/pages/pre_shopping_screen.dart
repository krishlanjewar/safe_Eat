import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/features/pre_shopping/data/cart_manager.dart';
import 'package:safeat/features/pre_shopping/presentation/pages/cart_screen.dart';

class PreShoppingScreen extends StatefulWidget {
  const PreShoppingScreen({super.key});

  @override
  State<PreShoppingScreen> createState() => _PreShoppingScreenState();
}

class _PreShoppingScreenState extends State<PreShoppingScreen> {
  // Theme Colors (Consistent with app design)
  final Color _purpleMain = const Color(0xFF7B1FA2);
  final Color _bgCream = const Color(0xFFF7F5F0);
  final Color _softBlack = const Color(0xFF2D3436);

  // Dummy Data
  final List<FoodItem> _allFoodItems = [
    FoodItem(
      name: "Fresh Apples",
      imageIcon: Icons.apple,
      calories: 52,
      protein: 0.3,
      isHealthy: true,
      description: "Crunchy, sweet, and packed with fiber. Perfect for a quick healthy snack.",
    ),
    FoodItem(
      name: "Potato Chips",
      imageIcon: Icons.fastfood,
      calories: 536,
      protein: 7.0,
      isHealthy: false,
      description: "Highly processed, high in sodium and unhealthy fats. Limit consumption.",
    ),
    FoodItem(
      name: "Greek Yogurt",
      imageIcon: Icons.icecream,
      calories: 59,
      protein: 10.0,
      isHealthy: true,
      description: "A protein powerhouse with probiotics for gut health.",
    ),
    FoodItem(
      name: "Classic Cola",
      imageIcon: Icons.local_drink,
      calories: 140,
      protein: 0.0,
      isHealthy: false,
      description: "Extremely high in refined sugar. Leads to insulin spikes.",
    ),
    FoodItem(
      name: "Chicken Breast",
      imageIcon: Icons.restaurant,
      calories: 165,
      protein: 31.0,
      isHealthy: true,
      description: "Excellent lean protein source for muscle repair and growth.",
    ),
    FoodItem(
      name: "Whole Wheat Bread",
      imageIcon: Icons.bakery_dining,
      calories: 247,
      protein: 13.0,
      isHealthy: true,
      description: "Complex carbohydrates that provide steady energy throughout the day.",
    ),
  ];

  late List<FoodItem> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = _allFoodItems;
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _allFoodItems
          .where(
            (item) => item.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _showFoodDetails(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle for bottom sheet
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: item.isHealthy
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.imageIcon,
                      size: 32,
                      color: item.isHealthy ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1C1E),
                          ),
                        ),
                        Text(
                          item.isHealthy
                              ? "Nutritious Choice"
                              : "Occasional Treat",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: item.isHealthy ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNutritionInfo("Energy", "${item.calories} kcal"),
                  _buildNutritionInfo("Protein", "${item.protein}g"),
                  _buildNutritionInfo(
                    "Health",
                    item.isHealthy ? "High" : "Low",
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Why buy this?",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: const Color(0xFF4B5563),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    cartManager.addItem(item);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${item.name} added to shopping list"),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Add to Shopping List",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FBF9),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_basket_rounded,
                    color: Color(0xFF10B981),
                    size: 64,
                  ),
                ).animate().scale(delay: 200.ms).fadeIn(),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.translate('pantry_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.translate('pantry_desc'),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: const Color(0xFF1A1C1E).withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0, delay: 100.ms).fadeIn(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                      if (mounted)
                        setState(() {}); // Refresh to check auth again
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('login_button'),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, end: 0, delay: 200.ms).fadeIn(),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.translate('pantry_title'),
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF10B981),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.translate('pantry_desc'),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterItems,
                    decoration: InputDecoration(
                      hintText: "Search items...",
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF10B981),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.04),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return InkWell(
                    onTap: () => _showFoodDetails(context, item),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.04),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: item.isHealthy
                                  ? const Color(0xFF10B981).withOpacity(0.05)
                                  : Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              item.imageIcon,
                              color: item.isHealthy
                                  ? const Color(0xFF10B981)
                                  : Colors.red[400],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1C1E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "${item.calories} kcal • ${item.protein}g protein",
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
