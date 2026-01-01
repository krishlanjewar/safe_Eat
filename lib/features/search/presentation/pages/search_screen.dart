import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/features/navigation/bottom_navigation.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:safeat/features/product/presentation/pages/product_detail_screen.dart';
import 'package:safeat/core/localization/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Product> _searchResults = [];

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
            parametersList: [
              SearchTerms(terms: [query]),
            ],
            version: ProductQueryVersion.v3,
            language: OpenFoodFactsLanguage.ENGLISH,
            country: OpenFoodFactsCountry.USA,
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
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_searchResults.isEmpty && !_isLoading) ...[
                    // Top Searches
                    Text(
                      AppLocalizations.of(context)!.translate('search_popular'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildSearchChip(
                          AppLocalizations.of(
                            context,
                          )!.translate('search_popular_oats'),
                          "Oats",
                        ),
                        _buildSearchChip(
                          AppLocalizations.of(
                            context,
                          )!.translate('search_popular_muesli'),
                          "Muesli",
                        ),
                        _buildSearchChip(
                          AppLocalizations.of(
                            context,
                          )!.translate('search_popular_yogurt'),
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
                    const SizedBox(height: 32),

                    // Snacky Banner
                    _buildSnackyBanner(),
                    const SizedBox(height: 32),

                    // Categories Grid
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.translate('home_categories'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _performSearch(categories[index]['name']),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.04),
                                    ),
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
                  ] else ...[
                    // Search Results
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _searchResults[index];
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              image: product.imageFrontUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        product.imageFrontUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: product.imageFrontUrl == null
                                ? const Icon(Icons.fastfood, color: Colors.grey)
                                : null,
                          ),
                          title: Text(
                            product.productName ??
                                AppLocalizations.of(
                                  context,
                                )!.translate('search_no_product'),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            product.brands ??
                                AppLocalizations.of(
                                  context,
                                )!.translate('search_no_brand'),
                            style: GoogleFonts.outfit(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.04),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String displayLabel, String query) {
    return GestureDetector(
      onTap: () => _performSearch(query),
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
