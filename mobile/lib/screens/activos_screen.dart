
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActivosScreen extends StatelessWidget {
  final int ubicacionId;
  final String ubicacionNombre;

  const ActivosScreen({super.key, required this.ubicacionId, required this.ubicacionNombre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activos: $ubicacionNombre"),
        backgroundColor: Colors.orangeAccent, // Color naranja para Activos
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.orange),
                  title: Text(activo["nombre"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Estado: ${activo['estado'] ?? 'Sin asignar'}"),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    // Aquí es donde usaremos esa acción '@action movimientos' que tienes en Django
                    print("Ver detalle del activo: ${activo['id']}");
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