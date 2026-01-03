import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeat/features/auth/presentation/pages/login_page.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/features/pre_shopping/data/cart_manager.dart';
import 'package:safeat/features/pre_shopping/presentation/pages/cart_screen.dart';
import 'package:safeat/features/pre_shopping/presentation/widgets/category_items_screen.dart';

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
  final List<Map<String, dynamic>> shoppingCategories = [
    {
      'name': 'Biscuits',
      'icon': Icons.cookie_outlined,
      'search_key': 'biscuits',
    },
    {
      'name': 'Breakfast',
      'icon': Icons.breakfast_dining_outlined,
      'search_key': 'breakfast cereal spread',
    },
    {
      'name': 'Chocolates',
      'icon': Icons.icecream_outlined,
      'search_key': 'chocolate dessert',
    },
    {
      'name': 'Drinks',
      'icon': Icons.local_drink_outlined,
      'search_key': 'juice soda',
    },
    {
      'name': 'Dairy & Eggs',
      'icon': Icons.egg_outlined,
      'search_key': 'dairy bread egg',
    },
    {
      'name': 'Instant',
      'icon': Icons.bolt_outlined,
      'search_key': 'instant noodles',
    },
    {
      'name': 'Munchies',
      'icon': Icons.fastfood_outlined,
      'search_key': 'snacks chips',
    },
    {'name': 'Bakes', 'icon': Icons.cake_outlined, 'search_key': 'cake bakery'},
    {
      'name': 'Spices & Oil',
      'icon': Icons.grain_outlined,
      'search_key': 'dry fruits oil spices',
    },
    {
      'name': 'Meat',
      'icon': Icons.restaurant_outlined,
      'search_key': 'meat chicken fish',
    },
    {
      'name': 'Rice & Dals',
      'icon': Icons.grass_outlined,
      'search_key': 'rice flour pulses',
    },
    {
      'name': 'Tea & Coffee',
      'icon': Icons.coffee_outlined,
      'search_key': 'tea coffee',
    },
  ];

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
                  "Smart Shopping List",
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                  textAlign: TextAlign.center,
                ).animate().slideY(begin: 0.2, end: 0).fadeIn(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Login to Start Planning"),
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
          "Pre-Shopping",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
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
              ValueListenableBuilder(
                valueListenable: cartManager.cartItems,
                builder: (context, items, _) => items.isEmpty
                    ? const SizedBox()
                    : Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            items.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      "Find healthy alternatives before you go!",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Food Categories",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: shoppingCategories.length,
                itemBuilder: (context, index) {
                  final cat = shoppingCategories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryItemsScreen(
                            categoryName: cat['name'] as String,
                            searchKey: cat['search_key'] as String,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                cat['icon'] as IconData,
                                color: const Color(0xFF10B981),
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).scale();
                },
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
