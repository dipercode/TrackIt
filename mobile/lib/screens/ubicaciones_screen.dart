
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activos_screen.dart';
import 'qr_scanner_screen.dart';

class UbicacionesScreen extends StatelessWidget {
  final int estacionId;
  final String estacionNombre;

  const UbicacionesScreen({
    super.key, 
    required this.estacionId, 
    required this.estacionNombre
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubicaciones: $estacionNombre"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "Escanear QR de Activo",
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getUbicaciones(estacionId), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text("⚠️ Error: ${snapshot.error}"),
            );
          }
          
          final ubicaciones = snapshot.data ?? [];
          
          if (ubicaciones.isEmpty) {
            return const Center(
              child: Text("No hay ubicaciones registradas en esta sede"),
            );
          }

          return ListView.separated(
            itemCount: ubicaciones.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final ubi = ubicaciones[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined, color: Colors.blue),
                title: Text(
                  ubi["nombre"],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text("ID de ubicación: ${ubi['id']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  debugPrint("Seleccionada Ubicación ID: ${ubi['id']}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivosScreen(
                        ubicacionId: ubi['id'],
                        ubicacionNombre: ubi['nombre'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}