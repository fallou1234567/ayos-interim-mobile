
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';

class MissionQrScannerScreen extends StatefulWidget {
  const MissionQrScannerScreen({super.key});

  @override
  State<MissionQrScannerScreen> createState() =>
      _MissionQrScannerScreenState();
}

class _MissionQrScannerScreenState
    extends State<MissionQrScannerScreen> {
  final MobileScannerController _controller =
      MobileScannerController();

  bool _detected = false;

  static const String _qrPrefix = 'ayos:clocking:v1:';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_detected) return;

    for (final barcode in capture.barcodes) {
      final payload = barcode.rawValue?.trim();

      if (payload == null || payload.isEmpty) continue;

      debugPrint('QR DETECTE : $payload');

      if (!payload.startsWith(_qrPrefix)) {
        debugPrint('QR IGNORE : format non reconnu');
        continue;
      }

      // Extraction du token sans le préfixe
      final qrToken = payload.substring(_qrPrefix.length).trim();

      if (qrToken.isEmpty) {
        debugPrint('QR IGNORE : token vide');
        continue;
      }

      _detected = true;

      debugPrint('QR AYOSTAFF VALIDE');
      debugPrint('QR TOKEN : $qrToken');
      debugPrint('FERMETURE DU SCANNER');

      await _controller.stop();

      if (!mounted) return;

      debugPrint('RETOUR VERS LE DETAIL MISSION');

      // Retourne uniquement le token brut
      Navigator.of(context).pop(qrToken);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner le QR Code'),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.navy,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Placez le QR Code de votre établissement '
                'dans le cadre pour enregistrer votre pointage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
