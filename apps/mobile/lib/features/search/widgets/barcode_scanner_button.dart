import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerButton extends StatelessWidget {
  const BarcodeScannerButton({super.key, required this.onScanned});

  final ValueChanged<String> onScanned;

  Future<void> _openScanner(BuildContext context) async {
    final controller = MobileScannerController();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Scan product barcode'),
              ),
              Expanded(
                child: MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull?.rawValue;
                    if (barcode != null && barcode.isNotEmpty) {
                      Navigator.of(context).pop();
                      onScanned(barcode);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openScanner(context),
      icon: const Icon(Icons.qr_code_scanner),
      tooltip: 'Scan barcode',
    );
  }
}
