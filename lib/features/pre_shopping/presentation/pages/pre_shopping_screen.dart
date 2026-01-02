import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/food_item.dart';

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
  final List<FoodItem> _foodItems = [
    FoodItem(
      name: "Fresh Apples",
      imageIcon: Icons.apple,
      calories: 52,
      protein: 0.3,
      isHealthy: true,
      description: "Crunchy, sweet, and packed with fiber. Perfect for a quick healthy snack.",
    ),
    FoodItem(
      name: "Crispy Potato Chips",
      imageIcon: Icons.fastfood,
      calories: 536,
      protein: 7.0,
      isHealthy: false,
      description: "Highly processed, high in sodium and unhealthy fats. Limit consumption.",
    ),
    FoodItem(
      name: "Greek Yogurt (Plain)",
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
      name: "Grilled Chicken Breast",
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

  void _showFoodDetails(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: item.isHealthy ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      item.imageIcon,
                      size: 36,
                      color: item.isHealthy ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _softBlack,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.isHealthy ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.isHealthy ? "✅ Healthy & Safe" : "❌ High Risk / Unsafe",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: item.isHealthy ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Text(
                "Nutrition Highlights",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _softBlack,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                   _buildNutritionCard("Calories", "${item.calories}", "kcal", Colors.orange),
                   const SizedBox(width: 12),
                   _buildNutritionCard("Protein", "${item.protein}", "g", Colors.blue),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Text(
                "Why buy this?",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _softBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  height: 1.5,
                  color: _softBlack.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${item.name} added to your shopping list!"),
                        backgroundColor: _purpleMain,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purpleMain,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        "Add to My List",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  Widget _buildNutritionCard(String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: color.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Pre-Shopping Tracker",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _softBlack,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _foodItems.length,
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFoodDetails(context, item),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _purpleMain.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(item.imageIcon, color: _purpleMain, size: 28),
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
                                color: _softBlack,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.calories} kcal • ${item.protein}g protein",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: _softBlack.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
