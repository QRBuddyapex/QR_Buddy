import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class QrScanForFoodDelivery extends StatefulWidget {
  const QrScanForFoodDelivery({Key? key}) : super(key: key);

  @override
  State<QrScanForFoodDelivery> createState() => _QrScanForFoodDeliveryState();
}

class _QrScanForFoodDeliveryState extends State<QrScanForFoodDelivery>
    with SingleTickerProviderStateMixin {
  bool scanned = false;
  bool _errorShown = false;
  String? expectedRoomUuid;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    scanned = false;
    final arguments = Get.arguments as Map<String, dynamic>?;
    expectedRoomUuid = arguments?['room_uuid']?.toString();
    print('Expected room_uuid: $expectedRoomUuid');

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorderColor : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? AppColors.darkTextColor : AppColors.textColor,
              ),
        ),
        backgroundColor: isDark
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    final barcode =
                        capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
                    if (!scanned && barcode != null && barcode.rawValue != null) {
                      final scannedValue = barcode.rawValue!.trim();
                      print('Scanned value: $scannedValue');

                      String? extractedUuid;
                      if (scannedValue.contains('https://qrbuddy.in/buddy/') &&
                          scannedValue.contains('/en')) {
                        final startIndex =
                            scannedValue.indexOf('/buddy/') + '/buddy/'.length;
                        final endIndex = scannedValue.indexOf('/en');
                        if (startIndex >= 0 && endIndex > startIndex) {
                          extractedUuid =
                              scannedValue.substring(startIndex, endIndex);
                        }
                      }

                      scanned = true;

                      if (expectedRoomUuid != null &&
                          extractedUuid == expectedRoomUuid) {
                        Get.back(result: extractedUuid);
                      } else {
                        if (!_errorShown) {
                          _errorShown = true; // prevent repeat snackbar
                          Get.snackbar(
                            'Error',
                            'The scanned QR code does not match the expected room. Please scan the correct QR code.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 3),
                          );
                        }

                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              scanned = false;
                              _errorShown = false; // allow retry later
                            });
                          }
                        });
                      }
                    }
                  },
                ),
                CustomPaint(
                  painter: OverlayPainter(borderColor),
                  size: Size.infinite,
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final size = MediaQuery.of(context).size;
                    final scanAreaSize = size.width * 0.7;
                    final scanAreaTop = size.height / 2.7 - scanAreaSize / 2;
                    final scanAreaLeft = size.width * 0.15;

                    // animate only inside the scan area
                    final topOffset =
                        scanAreaTop + (scanAreaSize - 6) * _animation.value;

                    return Positioned(
                      top: topOffset,
                      left: scanAreaLeft,
                      child: Container(
                        width: scanAreaSize,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primaryColor.withOpacity(0.9),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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

class OverlayPainter extends CustomPainter {
  final Color borderColor;

  OverlayPainter(this.borderColor);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.6);

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    // transparent cutout
    final background = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()..addRect(scanArea);
    final combined = Path.combine(PathOperation.difference, background, cutout);

    canvas.drawPath(combined, overlayPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(scanArea, borderPaint);

    final cornerPaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // TL
    canvas.drawLine(scanArea.topLeft,
        scanArea.topLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanArea.topLeft,
        scanArea.topLeft + const Offset(0, cornerLength), cornerPaint);

    // TR
    canvas.drawLine(scanArea.topRight,
        scanArea.topRight - const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanArea.topRight,
        scanArea.topRight + const Offset(0, cornerLength), cornerPaint);

    // BL
    canvas.drawLine(scanArea.bottomLeft,
        scanArea.bottomLeft + const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanArea.bottomLeft,
        scanArea.bottomLeft - const Offset(0, cornerLength), cornerPaint);

    // BR
    canvas.drawLine(scanArea.bottomRight,
        scanArea.bottomRight - const Offset(cornerLength, 0), cornerPaint);
    canvas.drawLine(scanArea.bottomRight,
        scanArea.bottomRight - const Offset(0, cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
