import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'activo_detalle_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Controlador simplificado para evitar errores de versión
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool isScanCompleted = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear Activo"),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (!isScanCompleted) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                setState(() {
                  isScanCompleted = true;
                });
                
                int? activoId = int.tryParse(code);

                if (activoId != null) {
                  // Navegamos al detalle
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivoDetalleScreen(
                        activoId: activoId,
                        activoNombre: "ID: $activoId", 
                      ),
                    ),
                  );
                } else {
                  setState(() => isScanCompleted = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ Código QR no válido (debe ser un ID numérico)")),
                  );
                }
              }
            }
          }
        },
      ),
    );
  }
}