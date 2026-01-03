import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:safeat/features/product/presentation/pages/product_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safeat/main.dart';

/// A high-performance barcode scanning screen.
///
/// Provides both visual scanning via camera and manual barcode entry.
/// Matches detected barcodes against the OpenFoodFacts database.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _isScanning = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String code = barcode.rawValue!;
        debugPrint('Barcode found! $code');
        await _fetchProduct(code);
        break; // Process only first valid barcode
      }
    }
  }

  Future<void> _fetchProduct(String code) async {
    if (code.isEmpty) return;

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    try {
      // Fetch Product Data
      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        code,
        version: ProductQueryVersion.v3,
        fields: [ProductField.ALL],
        language: localeNotifier.value.languageCode == 'hi'
            ? OpenFoodFactsLanguage.HINDI
            : localeNotifier.value.languageCode == 'as'
            ? OpenFoodFactsLanguage.ASSAMESE
            : OpenFoodFactsLanguage.ENGLISH,
        country: OpenFoodFactsCountry.INDIA,
      );

      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
        configuration,
      );

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        if (mounted) {
          setState(() => _isLoading = false);
          // Navigate to Product Detail
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailScreen(product: result.product!),
            ),
          );
          // Resume scanning when back
          setState(() => _isScanning = true);
        }
      } else {
        _showErrorDialog("Product not found");
      }
    } catch (e) {
      _showErrorDialog("Error fetching product: $e");
    }
  }

  void _showManualEntryDialog() {
    final TextEditingController manualController = TextEditingController();
    setState(() => _isScanning = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Manual Entry",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter the 13-digit barcode number manually.",
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: manualController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "8901234567890",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanning = true);
            },
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final code = manualController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(ctx);
                _fetchProduct(code);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Search", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Oops"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanning = true);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFF10B981),
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
                overlayColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // Header
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "Scan Barcode",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Align code within the frame",
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Manual Entry Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: _showManualEntryDialog,
                icon: const Icon(Icons.keyboard, color: Colors.white),
                label: Text(
                  "Enter Code Manually",
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal custom overlay shape class to mimic standard detailed scanners
// Or use library provided if available. MobileScanner doesn't provide QrScannerOverlayShape built-in usually?
// Actually MobileScanner does not have QrScannerOverlayShape. It's often from qr_code_scanner package.
// I will implement a custom simple painter or just use containers for the visual guide.
// Re-checking imports. MobileScanner doesn't export QrScannerOverlayShape.
// I'll replace ShapeDecoration with a simpler UI or valid code.

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double cutOutWidth = cutOutSize < width ? cutOutSize : width - 30;
    final double cutOutHeight = cutOutSize < height ? cutOutSize : height - 30;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, width, height))
      ..addRect(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutWidth,
          height: cutOutHeight,
        ),
      );

    return path..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double width = rect.width;
    final double height = rect.height;
    final double cutOutWidth = cutOutSize < width ? cutOutSize : width - 30;
    final double cutOutHeight = cutOutSize < height ? cutOutSize : height - 30;

    final Paint paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Draw Overlay
    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRect(cutOutRect),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw Corners
    final double tl = cutOutRect.left;
    final double tr = cutOutRect.right;
    final double tt = cutOutRect.top;
    final double tb = cutOutRect.bottom;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(tl, tt + borderLength)
        ..lineTo(tl, tt)
        ..lineTo(tl + borderLength, tt),
      borderPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(tr - borderLength, tt)
        ..lineTo(tr, tt)
        ..lineTo(tr, tt + borderLength),
      borderPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(tr, tb - borderLength)
        ..lineTo(tr, tb)
        ..lineTo(tr - borderLength, tb),
      borderPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(tl + borderLength, tb)
        ..lineTo(tl, tb)
        ..lineTo(tl, tb - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
