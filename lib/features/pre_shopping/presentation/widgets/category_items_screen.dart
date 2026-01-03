import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/pre_shopping/data/usda_service.dart';
import 'package:safeat/features/pre_shopping/data/cart_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;
  final String searchKey;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName,
    required this.searchKey,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final USDAService _usdaService = USDAService();
  bool _isLoading = true;
  List<USDAFoodItem> _items = [];
  String? _error;
  late String _currentCategory;
  late String _currentSearchKey;

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
  void initState() {
    super.initState();
    _currentCategory = widget.categoryName;
    _currentSearchKey = widget.searchKey;
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final items = await _usdaService.searchFoods(_currentSearchKey);
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showUSDAFoodDetails(USDAFoodItem usdaItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final calories = usdaItem.nutrients.firstWhere(
          (n) => n['name'].toString().toLowerCase().contains('energy'),
          orElse: () => {'amount': 0},
        )['amount'];
        final protein = usdaItem.nutrients.firstWhere(
          (n) => n['name'].toString().toLowerCase().contains('protein'),
          orElse: () => {'amount': 0},
        )['amount'];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                usdaItem.description,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              if (usdaItem.brandOwner != null)
                Text(
                  usdaItem.brandOwner!,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard("Calories", "$calories kcal"),
                  _buildInfoCard("Protein", "${protein}g"),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Explanation (USDA Insight)",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Text(
                    usdaItem.ingredients ??
                        "No ingredient information available for this product.",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: const Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    cartManager.addItem(
                      FoodItem(
                        name: usdaItem.description,
                        imageIcon: Icons.shopping_bag_outlined,
                        calories: calories.toInt(),
                        protein: protein.toDouble(),
                        isHealthy: true,
                        description: usdaItem.ingredients ?? "",
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Added ${usdaItem.description} to cart"),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Add to Shopping List"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            ),
          ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _currentCategory,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FBF9),
              border: Border(
                right: BorderSide(color: Colors.black.withOpacity(0.05)),
              ),
            ),
            child: ListView.builder(
              itemCount: shoppingCategories.length,
              itemBuilder: (context, index) {
                final cat = shoppingCategories[index];
                final isSelected = cat['name'] == _currentCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentCategory = cat['name'] as String;
                      _currentSearchKey = cat['search_key'] as String;
                    });
                    _fetchItems();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: isSelected
                          ? const Border(
                              left: BorderSide(
                                color: Color(0xFF10B981),
                                width: 4,
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  )
                : _error != null
                ? Center(child: Text(_error!))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return GestureDetector(
                            onTap: () => _showUSDAFoodDetails(item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0FDF4),
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.fastfood_outlined,
                                          size: 36,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.brandOwner ?? "Generic",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (index * 40).ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
