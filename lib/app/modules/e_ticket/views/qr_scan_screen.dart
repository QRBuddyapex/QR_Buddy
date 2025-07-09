import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({Key? key}) : super(key: key);

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
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
                  scanned = true;
                  Get.back(result: barcode.rawValue);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
