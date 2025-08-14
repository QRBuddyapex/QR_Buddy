import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_buddy/app/core/theme/app_theme.dart';

class QrScanForFoodDelivery extends StatefulWidget {
  const QrScanForFoodDelivery({Key? key}) : super(key: key);

  @override
  State<QrScanForFoodDelivery> createState() => _QrScanForFoodDeliveryState();
}

class _QrScanForFoodDeliveryState extends State<QrScanForFoodDelivery> {
  bool scanned = false;
  String? expectedRoomUuid;

  @override
  void initState() {
    super.initState();
 
    scanned = false;
    final arguments = Get.arguments as Map<String, dynamic>?;
    expectedRoomUuid = arguments?['room_uuid']?.toString();
    print('Expected room_uuid: $expectedRoomUuid');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextColor
                    : AppColors.textColor,
              ),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackgroundColor
            : AppColors.cardBackgroundColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: (capture) {
                final barcode =
                    capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
                if (!scanned && barcode != null && barcode.rawValue != null) {
                  final scannedValue = barcode.rawValue!.trim(); 
                  print('Scanned value: $scannedValue'); 

                
                  String? extractedUuid;
                  if (scannedValue.contains('https://qrbuddy.in/buddy/') &&
                      scannedValue.contains('/en')) {
                    final startIndex = scannedValue.indexOf('/buddy/') + '/buddy/'.length;
                    final endIndex = scannedValue.indexOf('/en');
                    if (startIndex >= 0 && endIndex > startIndex) {
                      extractedUuid = scannedValue.substring(startIndex, endIndex);
                    }
                  }

                  scanned = true; 
                  if (expectedRoomUuid != null && extractedUuid == expectedRoomUuid) {
                    Get.back(result: extractedUuid); 
                  } else {
                    Get.snackbar(
                      'Error',
                      'Scanned QR code does not match the room UUID. Expected: $expectedRoomUuid, Scanned: $extractedUuid',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                 
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        setState(() {
                          scanned = false;
                        });
                      }
                    });
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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