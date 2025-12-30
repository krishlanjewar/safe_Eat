import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors extracted from image
    final purpleGradientStart = const Color(0xFF9333EA); // Vibrant Purple
    final purpleGradientEnd = const Color(0xFF7C3AED); // Deep Purple
    final sectionTitleColor = const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Section (Gradient Background)
            _buildHeader(purpleGradientStart, purpleGradientEnd),

            // 2. Main Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Trial Banner
                  _buildTrialBanner(),

                  const SizedBox(height: 24),

                  // Top Categories
                  _buildSectionHeader('Top Categories', actionText: 'View All'),
                  const SizedBox(height: 16),
                  _buildCategoriesGrid(),

                  const SizedBox(height: 24),

                  // Tia Banner (Big Purple Card)
                  _buildTiaBanner(),

                  const SizedBox(height: 24),

                  // Weekly Healthy Picks
                  _buildSectionHeader('Weekly Healthy Picks'),
                  const SizedBox(height: 16),
                  _buildHealthyPicksList(),

                  const SizedBox(height: 24),

                  // Latest News (Based on Image 2)
                  _buildSectionHeader('Latest News'),
                  const SizedBox(height: 16),
                  _buildNewsCard(),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color startColor, Color endColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Greeting + Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi Competition,',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to make a smart choice?',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAvatarBadge(),
            ],
          ),

          const SizedBox(height: 24),

          // Search Bar & Veg Toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Search to find what fits you',
                        style: GoogleFonts.outfit(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildVegToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBadge() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.person, color: Color(0xFF4338CA)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Trial',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "10",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.monetization_on, size: 14, color: Colors.amber),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVegToggle() {
    return Column(
      children: [
        Text(
          'VEG',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: 44,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.circle, color: Colors.green, size: 18),
                ),
              ),
              // Simulated toggle thumb
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrialBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(
          'Your Free Trial Ends In 3 Days',
          style: GoogleFonts.outfit(
            color: const Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7C3AED)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        if (actionText != null)
          Text(
            actionText,
            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 14),
          ),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {'name': 'Biscuits', 'color': Colors.blue[50]},
      {'name': 'Breakfast & Spreads', 'color': Colors.red[50]},
      {'name': 'Chocolates & Desserts', 'color': Colors.purple[50]},
      {'name': 'Cold Drinks & Juices', 'color': Colors.orange[50]},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            width: 80,
            child: Column(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: cat['color'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // Placeholder for product image
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.black26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTiaBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF), // Light purple bg
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          alignment: Alignment.centerRight,
          // Placeholder for background texture
          image: NetworkImage('https://placehold.co/1x1/png'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SAY HELLO TO TIA',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: const Color(0xFF4C1D95),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: Text(
              'Want more than what meets the eye? Try the improved TIA to check products and discover healthier swaps.',
              style: GoogleFonts.outfit(
                color: const Color(0xFF4B5563),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D28D9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Chat With TIA'),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyPicksList() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPickCard('Fruit & Nut Treats', const Color(0xFFF3F4F6)),
          const SizedBox(width: 12),
          _buildPickCard('Clean Comfort Soups', const Color(0xFFFFF7ED)),
          const SizedBox(width: 12),
          _buildPickCard('Protein Packed Bars', const Color(0xFFECFDF5)),
        ],
      ),
    );
  }

  Widget _buildPickCard(String title, Color bg) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: const Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          // Placeholder for product image
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.black12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.article_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"ORS" Term Banned from Food and Drink Labels in India',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'India Today',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Read more',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF7C3AED),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
