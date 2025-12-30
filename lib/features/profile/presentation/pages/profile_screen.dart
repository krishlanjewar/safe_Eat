import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Premium Color Palette
    final emeraldPrimary = const Color(0xFF10B981);
    final sageSoft = const Color(0xFFD1FAE5);
    final slateDark = const Color(0xFF1F2937); // Text
    final warningRed = const Color(0xFFEF4444);
    final warningBg = const Color(0xFFFEF2F2);
    final softGray = const Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Health Payload',
          style: GoogleFonts.outfit(
            color: slateDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: slateDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Basic Profile Header
            _buildProfileHeader(emeraldPrimary, slateDark),

            const SizedBox(height: 24),

            // 2. Medical History (CRITICAL SAFETY LAYER)
            _buildSectionTitle('Medical Safety Context', slateDark),
            _buildMedicalContextCard(warningRed, warningBg, slateDark),

            const SizedBox(height: 24),

            // 3. Dietary Preferences
            _buildSectionTitle('Dietary Configuration', slateDark),
            _buildDietaryPreferences(emeraldPrimary, sageSoft),

            const SizedBox(height: 24),

            // 4. Food Scan Reports
            _buildSectionTitle('Recent Intake Scans', slateDark),
            _buildScanHistory(emeraldPrimary, slateDark),

            const SizedBox(height: 24),

            // 5. Trends
            _buildSectionTitle('Progress & Trends', slateDark),
            _buildTrendChart(emeraldPrimary),

            const SizedBox(height: 40),

            // 6. Footer / Data Control
            _buildFooter(slateDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color primary, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar with Health Ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primary, width: 3),
                ),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '92/100',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // User Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Krish, 24 M',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: text,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildVitalPill('178 cm'),
                    const SizedBox(width: 8),
                    _buildVitalPill('75 kg'),
                    const SizedBox(width: 8),
                    _buildVitalPill('BMI: 23.6'),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Activity: Moderate Exercise',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: const Color(0xFF374151),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMedicalContextCard(Color alertColor, Color bg, Color text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: alertColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'ACTIVE CONDITIONS',
                style: GoogleFonts.outfit(
                  color: alertColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildConditionChip('Type 2 Diabetes', alertColor),
              _buildConditionChip('Hypertension', alertColor),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Icon(Icons.medication_outlined, color: text, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Medications',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMedicationRow('Metformin', '500mg - Morning', true),
          _buildMedicationRow('Lisinopril', '10mg - Night', false),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: alertColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: alertColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Avoid Grapefruit: Interacts with your medication.',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF7F1D1D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMedicationRow(String name, String dosage, bool taken) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: taken ? const Color(0xFF10B981) : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: GoogleFonts.outfit(color: const Color(0xFF374151)),
              ),
            ],
          ),
          Text(
            dosage,
            style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferences(Color primary, Color secondary) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(left: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDietOption('Vegan', Icons.eco, true, primary, secondary),
          _buildDietOption(
            'Gluten Free',
            Icons.grass,
            false,
            primary,
            secondary,
          ),
          _buildDietOption('Halal', Icons.star, false, primary, secondary),
          _buildCautionOption('Peanuts'),
          _buildCautionOption('Shellfish'),
        ],
      ),
    );
  }

  Widget _buildDietOption(
    String label,
    IconData icon,
    bool isSelected,
    Color primary,
    Color bg,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? bg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primary : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? primary : Colors.grey, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? primary : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCautionOption(String label) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, color: Color(0xFFEF4444), size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFFB91C1C),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanHistory(Color primary, Color text) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 280,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      // Placeholder for scan image
                      image: NetworkImage('https://placehold.co/100x100/png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Oatmeal & Berries',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                      ),
                      Text(
                        'Today, 8:30 AM',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mini macros
                      Row(
                        children: [
                          _buildMacroDot('320 kcal', primary),
                          const SizedBox(width: 8),
                          _buildMacroDot('Low Sugar', primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTrendChart(Color primary) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 3),
                FlSpot(1, 4),
                FlSpot(2, 3.5),
                FlSpot(3, 5),
                FlSpot(4, 4),
                FlSpot(5, 6),
                FlSpot(6, 6.5),
              ],
              isCurved: true,
              color: primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Color text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export Health Report (PDF)'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your medical data is encrypted and stored locally on your device.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 10),
          ),
        ],
      ),
    );
  }
}
