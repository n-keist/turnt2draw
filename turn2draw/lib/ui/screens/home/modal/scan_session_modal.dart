import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class ScanSessionModal extends StatefulWidget {
  const ScanSessionModal({super.key});

  @override
  State<ScanSessionModal> createState() => _ScanSessionModalState();
}

class _ScanSessionModalState extends State<ScanSessionModal> {
  final controller = QRCodeDartScanController();

  @override
  Widget build(BuildContext context) {
    return QRCodeDartScanView(
      controller: controller,
      typeScan: TypeScan.live,
      formats: const [BarcodeFormat.QR_CODE],
      onCapture: (result) {
        context.pop(result.text);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
