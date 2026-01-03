import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:safeat/features/product/presentation/pages/product_detail_screen.dart';
import 'package:safeat/core/localization/app_localizations.dart';
import 'package:safeat/main.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A screen that allows users to search for food products using the OpenFoodFacts API.
///
/// Features include:
/// - Search-as-you-type with debouncing.
/// - Persisted search history.
/// - Support for an [initialQuery] triggered from external screens.
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<Product> _searchResults = [];
  bool _hasSearched = false;
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('search_history') ?? [];
    });
  }

  Future<void> _addToHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) _searchHistory.removeLast();
    await prefs.setStringList('search_history', _searchHistory);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    setState(() {
      _searchHistory = [];
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    // Add to history only if it's a manual search (optional: could add always)
    _addToHistory(query);

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
            parametersList: [
              SearchTerms(terms: [query]),
              const PageSize(size: 24),
            ],
            version: ProductQueryVersion.v3,
            fields: [
              ProductField.NAME,
              ProductField.BRANDS,
              ProductField.IMAGE_FRONT_URL,
              ProductField.NUTRISCORE,
              ProductField.ECOSCORE_GRADE,
              ProductField.NOVA_GROUP,
              ProductField.INGREDIENTS_TEXT,
              ProductField.NUTRIMENTS,
              ProductField.BARCODE,
            ],
            language: _getLanguage(),
            country: OpenFoodFactsCountry.INDIA,
          );

      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null,
        configuration,
      );

      if (mounted) {
        setState(() {
          _searchResults = result.products ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              )!.translate('search_error', {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  OpenFoodFactsLanguage _getLanguage() {
    final code = localeNotifier.value.languageCode;
    if (code == 'hi') return OpenFoodFactsLanguage.HINDI;
    if (code == 'as') return OpenFoodFactsLanguage.ASSAMESE;
    return OpenFoodFactsLanguage.ENGLISH;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'name_key': 'category_biscuits',
        'icon': Icons.cookie_outlined,
        'name': 'Biscuits',
      },
      {
        'name_key': 'category_breakfast',
        'icon': Icons.breakfast_dining_outlined,
        'name': 'Breakfast',
      },
      {
        'name_key': 'category_chocolates',
        'icon': Icons.icecream_outlined,
        'name': 'Chocolates',
      },
      {
        'name_key': 'category_drinks',
        'icon': Icons.local_drink_outlined,
        'name': 'Drinks',
      },
      {
        'name_key': 'category_dairy',
        'icon': Icons.egg_outlined,
        'name': 'Dairy',
      },
      {
        'name_key': 'category_instant',
        'icon': Icons.bolt_outlined,
        'name': 'Instant',
      },
      {
        'name_key': 'category_munchies',
        'icon': Icons.fastfood_outlined,
        'name': 'Munchies',
      },
      {
        'name_key': 'category_bakes',
        'icon': Icons.cake_outlined,
        'name': 'Bakes',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onSubmitted: _performSearch,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      )!.translate('search_placeholder'),
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF10B981),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                  _hasSearched = false;
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF10B981),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 24),

                  if (!_hasSearched) ...[
                    // Default View
                    if (_searchHistory.isNotEmpty) _buildHistorySection(),
                    const SizedBox(height: 24),
                    _buildPopularSearches(),
                    const SizedBox(height: 32),
                    _buildSnackyBanner().animate().scale(delay: 200.ms),
                    const SizedBox(height: 32),
                    _buildCategories(categories),
                  ] else if (_isLoading) ...[
                    _buildSkeletonLoader(),
                  ] else if (_searchResults.isEmpty) ...[
                    _buildEmptyState(),
                  ] else ...[
                    // Search Results
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        return _buildProductCard(product, index);
                      },
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
            // Removed fixed loading indicator as it's now a skeleton loader
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('search_popular'),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSearchChip(
              AppLocalizations.of(context)!.translate('search_popular_oats'),
              "Oats",
            ),
            _buildSearchChip(
              AppLocalizations.of(context)!.translate('search_popular_muesli'),
              "Muesli",
            ),
            _buildSearchChip(
              AppLocalizations.of(context)!.translate('search_popular_yogurt'),
              "Yogurt",
            ),
            _buildSearchChip(
              AppLocalizations.of(
                context,
              )!.translate('search_popular_dark_choc'),
              "Dark Chocolate",
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildCategories(List<Map<String, dynamic>> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('home_categories'),
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                _searchController.text = categories[index]['name'];
                _performSearch(categories[index]['name']);
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                          categories[index]['icon'],
                          color: const Color(0xFF10B981),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate(categories[index]['name_key']),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(fontSize: 12),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildProductCard(Product product, int index) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: product.imageFrontUrl != null
              ? Image.network(
                  product.imageFrontUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.fastfood, color: Colors.grey),
                )
              : const Icon(Icons.fastfood, color: Colors.grey),
        ),
      ),
      title: Text(
        product.productName ??
            AppLocalizations.of(context)!.translate('search_no_product'),
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: const Color(0xFF1A1C2E),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.brands ??
                AppLocalizations.of(context)!.translate('search_no_brand'),
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600]),
          ),
          if (product.nutriscore != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getNutriColor(product.nutriscore!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Nutri-Score: ${product.nutriscore!.toUpperCase()}",
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getNutriColor(product.nutriscore!),
                  ),
                ),
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.black.withOpacity(0.03)),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 15,
                          color: Colors.grey[100],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.grey[100],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: Colors.white.withOpacity(0.5));
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No products found",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          Text(
            "Try searching for something else",
            style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Color _getNutriColor(String score) {
    switch (score.toLowerCase()) {
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

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Searches",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: _clearHistory,
              child: const Text(
                "Clear",
                style: TextStyle(color: Color(0xFF10B981)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _searchHistory.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _buildSearchChip(
                _searchHistory[index],
                _searchHistory[index],
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSearchChip(String displayLabel, String query) {
    return GestureDetector(
      onTap: () {
        _searchController.text = query;
        _performSearch(query);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: Text(
          displayLabel,
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildSnackyBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  )!.translate('search_snacky_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.translate('search_snacky_desc'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => MainLayout.of(context)?.setIndex(4),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('search_start_chat'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(
            Icons.psychology_outlined,
            size: 60,
            color: Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}
