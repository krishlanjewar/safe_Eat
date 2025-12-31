import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreShoppingScreen extends StatefulWidget {
  const PreShoppingScreen({super.key});

  @override
  State<PreShoppingScreen> createState() => _PreShoppingScreenState();
}

class _PreShoppingScreenState extends State<PreShoppingScreen> {
  // Dummy Data
  final List<FoodItem> _foodItems = [
    FoodItem(
      name: "Apples",
      imageIcon: Icons.apple,
      calories: 52,
      protein: 0.3,
      isHealthy: true,
      description: "Rich in fiber and Vitamin C.",
    ),
    FoodItem(
      name: "Potato Chips",
      imageIcon: Icons.fastfood, // Using generic fastfood icon for chips
      calories: 536,
      protein: 7.0,
      isHealthy: false,
      description: "High in sodium and saturated fats.",
    ),
    FoodItem(
      name: "Greek Yogurt",
      imageIcon: Icons.icecream, // Closest to yogurt
      calories: 59,
      protein: 10.0,
      isHealthy: true,
      description: "Excellent source of protein and probiotics.",
    ),
    FoodItem(
      name: "Soda",
      imageIcon: Icons.local_drink,
      calories: 140,
      protein: 0.0,
      isHealthy: false,
      description: "High sugar content, no nutritional value.",
    ),
     FoodItem(
      name: "Chicken Breast",
      imageIcon: Icons.restaurant,
      calories: 165,
      protein: 31.0,
      isHealthy: true,
      description: "Lean protein source, low in fat.",
    ),
  ];

  void _showFoodDetails(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60, 
                  height: 60,
                  decoration: BoxDecoration(
                    color: item.isHealthy ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.imageIcon, size: 30, color: item.isHealthy ? Colors.green : Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  item.name,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.isHealthy ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isHealthy ? "✅ Healthy" : "❌ Not Healthy",
                    style: GoogleFonts.outfit(
                      color: item.isHealthy ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildNutritionInfo("Calories", "${item.calories} kcal"),
                   _buildNutritionInfo("Protein", "${item.protein}g"),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Description",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                item.description,
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${item.name} added to your shopping list!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B1FA2), // Purple 700
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: Text(
                    "Add to My List",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _buildNutritionInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pre-Shopping",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _foodItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _foodItems[index];
          return InkWell(
            onTap: () => _showFoodDetails(context, item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E5F5), // Purple 50
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.imageIcon, color: const Color(0xFF7B1FA2)), // Purple 700
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${item.calories} kcal • ${item.protein}g Protein",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF7B1FA2)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FoodItem {
  final String name;
  final IconData imageIcon;
  final int calories;
  final double protein;
  final bool isHealthy;
  final String description;

  FoodItem({
    required this.name,
    required this.imageIcon,
    required this.calories,
    required this.protein,
    required this.isHealthy,
    required this.description,
  });
}
