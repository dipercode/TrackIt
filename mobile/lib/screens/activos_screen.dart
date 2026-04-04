import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActivosScreen extends StatelessWidget {
  final int ubicacionId;
  final String ubicacionNombre;

  const ActivosScreen({super.key, required this.ubicacionId, required this.ubicacionNombre});

  // 🎨 Función auxiliar para determinar el color según el estado
  Color _getEstadoColor(String? estado) {
    if (estado == null) return Colors.grey;
    
    switch (estado.toLowerCase()) {
      case 'operativo':
        return Colors.green;
      case 'disponible':
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
                  // 🟢🟠🔴 El icono cambia de color según el estado
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
                    print("Ver detalle del activo ID: ${activo['id']}");
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