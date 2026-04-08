
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activo_detalle_screen.dart';
import 'qr_scanner_screen.dart';

class ActivosScreen extends StatelessWidget {
  final int ubicacionId;
  final String ubicacionNombre;

  const ActivosScreen({super.key, required this.ubicacionId, required this.ubicacionNombre});

  Color _getEstadoColor(String? estado) {
    if (estado == null) return Colors.grey;
    
    switch (estado.toLowerCase()) {
      case 'operativo':
        return Colors.green;
      case 'disponible':
      case 'traslado':
        return Colors.orange;
      case 'averiado':
      case 'reparación':
      case 'calibración':
      case 'baja':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activos: $ubicacionNombre"),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        // Sección de acciones en el AppBar
        actions: [
          IconButton(
            tooltip: "Escanear QR",
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
        future: ApiService.getActivos(ubicacionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final activos = snapshot.data ?? [];
          if (activos.isEmpty) {
            return const Center(child: Text("No hay activos en esta ubicación"));
          }

          return ListView.builder(
            itemCount: activos.length,
            itemBuilder: (context, index) {
              final activo = activos[index];
              final String estado = activo['estado'] ?? 'Sin asignar';
              final Color colorEstado = _getEstadoColor(estado);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: Icon(Icons.inventory_2, color: colorEstado), 
                  title: Text(
                    activo["nombre"], 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colorEstado,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("Estado: $estado"),
                    ],
                  ),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivoDetalleScreen(
                          activoId: activo['id'],
                          activoNombre: activo['nombre'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}