import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 24),
                _buildScoresSection(),
                const SizedBox(height: 24),
                _buildIngredientsSection(),
                const SizedBox(height: 24),
                _buildNutritionSection(),
                const SizedBox(height: 24),
                _buildAllergensSection(),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: product.barcode ?? 'product_image',
          child: product.imageFrontUrl != null
              ? Image.network(
                  product.imageFrontUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.productName ?? 'Unknown Product',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3436),
          ),
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          product.brands ?? 'Unknown Brand',
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        if (product.quantity != null)
          Text(
            product.quantity!,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildScoresSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildScoreBadge(
          'Nutri-Score',
          product.nutriscore?.toUpperCase() ?? '?',
          _getNutriScoreColor(product.nutriscore),
        ),
        _buildScoreBadge(
          'NOVA',
          product.novaGroup?.toString() ?? '?',
          _getNovaColor(product.novaGroup),
        ),
        _buildScoreBadge(
          'Eco-Score',
          product.ecoscoreGrade?.toUpperCase() ?? '?',
          _getEcoScoreColor(product.ecoscoreGrade),
        ),
      ],
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildScoreBadge(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            product.ingredientsText ?? 'Ingredients not available',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: const Color(0xFF2D3436),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: _buildAttributeChips()),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  List<Widget> _buildAttributeChips() {
    List<Widget> chips = [];

    // Safety handling for ingredientsAnalysisTags
    final dynamic tags = product.ingredientsAnalysisTags;
    List<String> safeTags = [];

    if (tags is List) {
      safeTags = tags.map((e) => e.toString()).toList();
    } else if (tags != null) {
      try {
        final wrapperTags = (tags as dynamic).tags;
        if (wrapperTags is List) {
          safeTags = wrapperTags.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // Fallback or ignore
      }
    }

    for (var tag in safeTags) {
      String label = tag.split(':').last.replaceAll('-', ' ');
      if (label.contains('vegan'))
        chips.add(_buildChip('Vegan', Colors.green));
      else if (label.contains('vegetarian'))
        chips.add(_buildChip('Vegetarian', Colors.green));
      else if (label.contains('palm oil free'))
        chips.add(_buildChip('Palm Oil Free', Colors.blue));
    }

    return chips;
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildNutritionSection() {
    final nutrients = product.nutriments;
    if (nutrients == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nutrition Facts (per 100g)",
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildNutrientRow(
          "Energy",
          "${nutrients.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams)?.toStringAsFixed(0) ?? '-'} kcal",
        ),
        _buildNutrientRow(
          "Fat",
          "${nutrients.getValue(Nutrient.fat, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
        ),
        _buildNutrientRow(
          "Saturated Fat",
          "${nutrients.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
          indent: true,
        ),
        _buildNutrientRow(
          "Carbohydrates",
          "${nutrients.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
        ),
        _buildNutrientRow(
          "Sugars",
          "${nutrients.getValue(Nutrient.sugars, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
          indent: true,
        ),
        _buildNutrientRow(
          "Fiber",
          "${nutrients.getValue(Nutrient.fiber, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
        ),
        _buildNutrientRow(
          "Proteins",
          "${nutrients.getValue(Nutrient.proteins, PerSize.oneHundredGrams)?.toStringAsFixed(1) ?? '-'} g",
        ),
        _buildNutrientRow(
          "Salt",
          "${nutrients.getValue(Nutrient.salt, PerSize.oneHundredGrams)?.toStringAsFixed(2) ?? '-'} g",
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildNutrientRow(String label, String value, {bool indent = false}) {
    return Padding(
      padding: EdgeInsets.only(left: indent ? 16.0 : 0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[800]),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergensSection() {
    final allergens = product.allergens;
    if (allergens == null || allergens.ids == null || allergens.ids!.isEmpty)
      return const SizedBox.shrink();

    // safe access removing !
    final ids = allergens.ids;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Red tint
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                "Allergens",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFB91C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ids!.map((e) => e.split(':').last).join(', '),
            style: GoogleFonts.outfit(color: const Color(0xFFB91C1C)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  // Helpers for Colors
  Color _getNutriScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }

  Color _getNovaColor(int? group) {
    switch (group) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEcoScoreColor(String? score) {
    switch (score?.toLowerCase()) {
      case 'a':
        return const Color(0xFF038141);
      case 'b':
        return const Color(0xFF85BB2F);
      case 'c':
        return const Color(0xFFFECB02);
      case 'd':
        return const Color(0xFFEE8100);
      case 'e':
        return const Color(0xFFE63E11);
      default:
        return Colors.grey;
    }
  }
}
