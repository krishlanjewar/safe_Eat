
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Category Data
    final List<Map<String, dynamic>> categories = [
      {'name': 'Biscuits', 'color': Colors.blue.shade50},
      {'name': 'Breakfast &\nSpreads', 'color': Colors.orange.shade50},
      {'name': 'Chocolates &\nDesserts', 'color': Colors.purple.shade50},
      {'name': 'Cold Drinks &\nJuices', 'color': Colors.yellow.shade50},
      {'name': 'Dairy, Bread &\nEggs', 'color': Colors.green.shade50},
      {'name': 'Instant Foods', 'color': Colors.red.shade50},
      {'name': 'Munchies', 'color': Colors.amber.shade50},
      {'name': 'Cakes & Bakes', 'color': Colors.pink.shade50},
      {'name': 'Dry Fruits, Oil &\nMasalas', 'color': Colors.brown.shade50},
      {'name': 'Meat', 'color': Colors.deepOrange.shade50},
      {'name': 'Rice, Atta &\nDals', 'color': Colors.cyan.shade50},
      {'name': 'Tea, Coffee &\nMore', 'color': Colors.teal.shade50},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Light background color from design
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Try searching for " Biscuits "',
                  hintStyle: GoogleFonts.outfit(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black, size: 28),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.black, size: 16),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filters Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Filters",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                         const Icon(Icons.tune_rounded, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: true, 
                    onChanged: (val) {},
                    activeThumbColor: Colors.green,
                    activeTrackColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[200],
                    trackOutlineColor: WidgetStateProperty.all(Colors.grey.shade300),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Top Searches
              Text(
                "Top Searches",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSearchChip("MAGGI", icon: Icons.search),
                  _buildSearchChip("ghee", icon: Icons.search),
                  _buildSearchChip("PEANUT BUTTER", icon: Icons.search),
                  _buildSearchChip("oats", icon: Icons.search),
                  _buildSearchChip("PANEER", icon: Icons.search),
                  _buildSearchChip("Muesli", icon: Icons.search),
                ],
              ),
              const SizedBox(height: 24),

              // TIA Banner
              Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [const Color(0xFFE1bee7), const Color(0xFFF3E5F5)], // Purple 100, Purple 50
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(24),
                 ),
                 child: Row(
                   children: [
                     Expanded(
                       flex: 3,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             "SAY HELLO TO SNACKY",
                             style: GoogleFonts.outfit(
                               fontSize: 22,
                               fontWeight: FontWeight.w800,
                               color: const Color(0xFF4A148C), // Deep purple
                               letterSpacing: 0.5,
                             ),
                           ),
                           const SizedBox(height: 8),
                           Text(
                             "Want more than what meets the eye? Try the improved Snacky to check products and discover healthier swaps.",
                             style: GoogleFonts.outfit(
                               fontSize: 13,
                               fontWeight: FontWeight.w400,
                               color: Colors.black87,
                               height: 1.4,
                             ),
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton(
                             onPressed: () {},
                             style: ElevatedButton.styleFrom(
                               backgroundColor: const Color(0xFF7B1FA2), // Purple 700
                               foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(30),
                               ),
                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                               elevation: 0,
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(
                                   "Chat With Snacky",
                                   style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13
                                   ),
                                 ),
                                 const SizedBox(width: 4),
                                 const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(width: 16),
                     // 3D Robot Icon Placeholder
                     Expanded(
                       flex: 2,
                       child: Icon(Icons.smart_toy_rounded, 
                         size: 80, 
                         color: const Color(0xFF7B1FA2).withValues(alpha: 0.8)
                       ),
                     ),
                   ],
                 ),
              ),
               const SizedBox(height: 24),

               // Categories

               GridView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 4,
                   mainAxisSpacing: 16,
                   crossAxisSpacing: 12,
                   childAspectRatio: 0.65,
                 ),
                 itemCount: categories.length,
                 itemBuilder: (context, index) {
                   return Column(
                     children: [
                       Expanded(
                         child: Container(
                           decoration: BoxDecoration(
                             color: const Color(0xFFFAEFFF), // categories[index]['color'], using a standard light background for consistency as per image looks like light grey/white/purple tint
                             borderRadius: BorderRadius.circular(16),
                             image: DecorationImage(
                                image: NetworkImage("https://via.placeholder.com/150"), // Placeholder until actual assets are available
                                fit: BoxFit.cover,
                                opacity: 0.0 // Hiding placeholder image for now to keep it clean, or could use an icon
                             ),
                           ),
                           child: Center(
                             child: Icon(Icons.fastfood, color: const Color(0xFF7B1FA2).withValues(alpha: 0.3), size: 30), // Placeholder icon
                           ),
                         ),
                       ),
                       const SizedBox(height: 8),
                       Text(
                         categories[index]['name'],
                         textAlign: TextAlign.center,
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                         style: GoogleFonts.outfit(
                           fontSize: 11,
                           fontWeight: FontWeight.w400,
                           color: Colors.black87,
                           height: 1.2,
                         ),
                       ),
                     ],
                   );
                 },
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
