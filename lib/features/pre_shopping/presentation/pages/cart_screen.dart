import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/pre_shopping/data/cart_manager.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text(
          "My Shopping List",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1C1E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.redAccent,
            ),
            onPressed: () => _showClearConfirmation(context),
            tooltip: "Clear All",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          "Add Item",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ValueListenableBuilder<List<FoodItem>>(
        valueListenable: cartManager.cartItems,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildNutritionSummary(context),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    8,
                    24,
                    100,
                  ), // Extra bottom padding for FAB
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildCartItem(context, item, index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    bool isHealthy = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            "Add Custom Item",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  nameController,
                  "Item Name",
                  Icons.shopping_bag_outlined,
                ),
                const SizedBox(height: 16),
                _buildDialogField(
                  calController,
                  "Calories (kcal)",
                  Icons.bolt,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDialogField(
                  proteinController,
                  "Protein (g)",
                  Icons.fitness_center,
                  type: TextInputType.number,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Is this healthy?",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                    Switch(
                      value: isHealthy,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) => setDialogState(() => isHealthy = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.outfit(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  cartManager.addItem(
                    FoodItem(
                      name: nameController.text,
                      imageIcon: isHealthy
                          ? Icons.eco_rounded
                          : Icons.fastfood_rounded,
                      calories: int.tryParse(calController.text) ?? 0,
                      protein: double.tryParse(proteinController.text) ?? 0,
                      isHealthy: isHealthy,
                      description: "Manually added item",
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Add to List",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF10B981), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: GoogleFonts.outfit(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_basket_outlined,
              color: Color(0xFF10B981),
              size: 64,
            ),
          ).animate().scale(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),
          Text(
            "Your list is empty",
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Go back and add some healthy items!",
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary(BuildContext context) {
    final healthy = cartManager.healthyCount;
    final unhealthy = cartManager.unhealthyCount;
    final total = cartManager.cartItems.value.length;
    final healthyPercent = total > 0 ? (healthy / total) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pantry Health",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                  ),
                  Text(
                    "$healthy Healthy • $unhealthy Less Healthy",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: healthyPercent,
                      backgroundColor: Colors.grey[100],
                      color: const Color(0xFF10B981),
                      strokeWidth: 5,
                    ),
                  ),
                  Text(
                    "${(healthyPercent * 100).toInt()}%",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[100]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallMetric(
                "Total Cal",
                "${cartManager.totalCalories.toInt()}",
              ),
              _buildSmallMetric(
                "Total Protein",
                "${cartManager.totalProtein.toStringAsFixed(1)}g",
              ),
              _buildSmallMetric("Items", "${cartManager.totalItemCount}"),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSmallMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1C1E),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, FoodItem item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isBought
              ? const Color(0xFF10B981).withOpacity(0.2)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: item.isBought,
              activeColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              onChanged: (val) {
                cartManager.toggleItemBought(index);
                if (val == true) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            "${item.name} is bought!",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.isHealthy
                  ? const Color(0xFF10B981).withOpacity(0.05)
                  : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              item.imageIcon,
              color: item.isHealthy ? const Color(0xFF10B981) : Colors.red[400],
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: item.isBought
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.isBought
                        ? Colors.grey
                        : const Color(0xFF1A1C1E),
                  ),
                ),
                Text(
                  "${item.calories} kcal • ${item.protein}g protein",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: item.isBought
                        ? Colors.grey.withOpacity(0.5)
                        : Colors.grey[500],
                    decoration: item.isBought
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(
                          maxHeight: 32,
                          maxWidth: 32,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.remove,
                          size: 14,
                          color: Color(0xFF1A1C1E),
                        ),
                        onPressed: () => cartManager.updateQuantity(index, -1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "${item.quantity}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints(
                          maxHeight: 32,
                          maxWidth: 32,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.add,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        onPressed: () => cartManager.updateQuantity(index, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[200], size: 20),
            onPressed: () => cartManager.removeItem(index),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Clear List?",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove all items from your shopping list?",
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              cartManager.clearCart();
              Navigator.pop(context);
            },
            child: Text(
              "Clear All",
              style: GoogleFonts.outfit(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
