import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/features/chatbot/data/gemini_service.dart';
import 'package:safeat/main.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Displays detailed information about a product and fetches AI-driven analysis.
///
/// Features:
/// - Visualizes Nutri-Score, Nova Group, and Eco-Score.
/// - Fetches a comprehensive safety breakdown from Gemini AI.
/// - Lists localized nutrition facts and ingredients.
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final GeminiService _geminiService = GeminiService();
  String? _aiAnalysis;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _fetchAIAnalysis();
  }

  Future<void> _fetchAIAnalysis() async {
    try {
      final productName = widget.product.productName ?? 'Unknown';
      final brands = widget.product.brands ?? 'Unknown';
      final nutriScore = widget.product.nutriscore ?? 'N/A';
      final novaGroup = widget.product.novaGroup?.toString() ?? 'N/A';
      final ecoScore = widget.product.ecoscoreGrade ?? 'N/A';
      final ingredientsList = widget.product.ingredients
          ?.map((e) => e.text)
          .whereType<String>()
          .join(', ');
      final ingredients =
          widget.product.ingredientsText ??
          (ingredientsList != null && ingredientsList.isNotEmpty
              ? ingredientsList
              : 'Not list available');
      final allergensList = widget.product.allergens?.ids;
      final allergens = allergensList?.join(', ') ?? 'None';

      final productInfo =
          """
        Analyze this product:
        Name: $productName
        Brand: $brands
        Nutri-score: $nutriScore
        Nova Group: $novaGroup
        Eco-score: $ecoScore
        Ingredients: $ingredients
        Allergens: $allergens

        Please follow these rules for your response:
        1. Start with exactly "Verdict: BUY" or "Verdict: NOT BUY" based on overall healthiness.
        2. Add a separator: "---".
        3. Provide a brief, friendly summary of the product (Snacky's Insight).
        4. Provide a markdown table for ingredients breakdown with columns: | Ingredient | What it does | Impact on Body |.
        5. For the Impact on Body column, use icons: 🟢 (Safe), 🟡 (Caution), 🔴 (Harmful).
        6. List any major allergy warnings.
        7. Suggest 2-3 healthier alternatives if the verdict is "NOT BUY".
        8. Use simple language that a child can understand.
      """;

      final response = await _geminiService.sendMessage(
        productInfo,
        languageCode: localeNotifier.value.languageCode,
      );

      if (mounted) {
        setState(() {
          _aiAnalysis = response;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiAnalysis =
              "Unable to get AI analysis right now. Please try again later.";
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF10B981);
    const Color backgroundColor = Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, primaryColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildDecisionHeading(context, primaryColor),
                  const SizedBox(height: 24),
                  _buildScoresSection(context),
                  const SizedBox(height: 32),
                  _buildAIAnalysisSection(context, primaryColor),
                  const SizedBox(height: 32),
                  _buildNutritionSection(context, primaryColor),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 380.0,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 18,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.product.barcode ?? 'product_image',
              child: widget.product.imageFrontUrl != null
                  ? Image.network(
                      widget.product.imageFrontUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.productName ??
                        AppLocalizations.of(
                          context,
                        )!.translate('product_unknown'),
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C2E),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.brands ??
                        AppLocalizations.of(
                          context,
                        )!.translate('product_unknown_brand'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color: const Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.product.quantity != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.product.quantity!,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoresSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            context,
            AppLocalizations.of(context)!.translate('product_nutri_score'),
            widget.product.nutriscore?.toUpperCase() ?? '?',
            _getNutriScoreColor(widget.product.nutriscore),
            Icons.health_and_safety_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            context,
            AppLocalizations.of(context)!.translate('product_nova_score'),
            widget.product.novaGroup?.toString() ?? '?',
            _getNovaColor(widget.product.novaGroup),
            Icons.precision_manufacturing_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildScoreCard(
            context,
            AppLocalizations.of(context)!.translate('product_eco_score'),
            widget.product.ecoscoreGrade?.toUpperCase() ?? '?',
            _getEcoScoreColor(widget.product.ecoscoreGrade),
            Icons.eco_outlined,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildScoreCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionHeading(BuildContext context, Color primaryColor) {
    if (_isAnalyzing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF10B981),
              strokeWidth: 3,
            ),
            const SizedBox(height: 12),
            Text(
              "Snacky AI is deciding...",
              style: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final parts = _aiAnalysis?.split('---') ?? [];
    final verdictPart = parts.isNotEmpty ? parts[0].trim() : "";

    final isBuy =
        verdictPart.toUpperCase().contains('BUY') &&
        !verdictPart.toUpperCase().contains('NOT BUY');
    final isNotBuy = verdictPart.toUpperCase().contains('NOT BUY');

    // Fallback if AI didn't follow the exact format but mentioned BUY/NOT BUY
    final bool decision =
        isBuy || (!isNotBuy && verdictPart.toUpperCase().contains('BUY'));

    final Color verdictColor = isBuy
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: verdictColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: verdictColor.withOpacity(0.2), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBuy ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: verdictColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                decision ? "Decision: BUY" : "Decision: NOT BUY",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: verdictColor,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          if (!isBuy) ...[
            const SizedBox(height: 8),
            Text(
              decision
                  ? "Snacky recommends this product!"
                  : "Snacky suggests caution for this product.",
              style: GoogleFonts.outfit(
                color: verdictColor.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildAIAnalysisSection(BuildContext context, Color primaryColor) {
    if (_isAnalyzing || _aiAnalysis == null) return const SizedBox.shrink();

    final parts = _aiAnalysis!.split('---');
    final details = parts.length > 1 ? parts[1].trim() : parts[0].trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Snacky's Insight",
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          MarkdownBody(
            data: details,
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.outfit(
                fontSize: 15,
                color: const Color(0xFF4B5563),
                height: 1.6,
              ),
              listBullet: GoogleFonts.outfit(color: primaryColor),
              strong: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1C3E),
              ),
              h1: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1C2E),
              ),
              tableBorder: TableBorder.all(color: Colors.grey[200]!, width: 1),
              tableBody: GoogleFonts.outfit(fontSize: 13),
              tableHead: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNutritionSection(BuildContext context, Color primaryColor) {
    final nutrients = widget.product.nutriments;
    if (nutrients == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(
                  context,
                )!.translate('product_nutrition_per_100g'),
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_energy'),
            "${_getNutrientValue(nutrients, Nutrient.energyKCal)?.toStringAsFixed(0) ?? '-'} kcal",
            const Color(0xFFF59E0B),
          ),
          _buildDivider(),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_proteins'),
            "${_getNutrientValue(nutrients, Nutrient.proteins)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFF10B981),
          ),
          _buildDivider(),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_carbohydrates'),
            "${_getNutrientValue(nutrients, Nutrient.carbohydrates)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFF3B82F6),
          ),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_sugars'),
            "${_getNutrientValue(nutrients, Nutrient.sugars)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFF6366F1),
            isSub: true,
          ),
          _buildDivider(),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_fat'),
            "${_getNutrientValue(nutrients, Nutrient.fat)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFFEF4444),
          ),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_saturated_fat'),
            "${_getNutrientValue(nutrients, Nutrient.saturatedFat)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFFB91C1C),
            isSub: true,
          ),
          _buildDivider(),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_fiber'),
            "${_getNutrientValue(nutrients, Nutrient.fiber)?.toStringAsFixed(1) ?? '-'} g",
            const Color(0xFF8B5CF6),
          ),
          _buildDivider(),
          _buildNutrientRow(
            AppLocalizations.of(context)!.translate('product_salt'),
            "${_getNutrientValue(nutrients, Nutrient.salt)?.toStringAsFixed(2) ?? '-'} g",
            const Color(0xFF6B7280),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  double? _getNutrientValue(Nutriments nutrients, Nutrient nutrient) {
    return nutrients.getValue(nutrient, PerSize.oneHundredGrams) ??
        nutrients.getValue(nutrient, PerSize.serving);
  }

  Widget _buildNutrientRow(
    String label,
    String value,
    Color color, {
    bool isSub = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isSub ? 20 : 0, top: 12, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (!isSub)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!isSub) const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isSub
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF1A1C2E),
                  fontWeight: isSub ? FontWeight.w500 : FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C3E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[100], height: 1);
  }

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
        return const Color(0xFF038141);
      case 2:
        return const Color(0xFFFECB02);
      case 3:
        return const Color(0xFFEE8100);
      case 4:
        return const Color(0xFFE63E11);
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
