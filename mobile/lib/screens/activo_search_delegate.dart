
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activo_detalle_screen.dart';

class ActivoSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar activo...';

  // Limpiar la búsqueda
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '', // query es lo que el usuario escribe
      ),
    ];
  }

  // Botón de volver atrás
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Resultados al presionar "Enter"
  @override
  Widget buildResults(BuildContext context) {
    return _construirListaResultados();
  }

  // Sugerencias mientras escribe, al menos 2 caracteres
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Escribe el nombre del activo'));
    }
    return _construirListaResultados();
  }

  // Widget común para mostrar los resultados
  Widget _construirListaResultados() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.buscarActivos(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No se encontraron activos'));
        }

        final activos = snapshot.data!;

        return ListView.builder(
          itemCount: activos.length,
          itemBuilder: (context, index) {
            final activo = activos[index];
            return ListTile(
              leading: const Icon(Icons.inventory_2),
              title: Text(activo['nombre']),
              subtitle: Text("Estado: ${activo['estado']}"),
              onTap: () {
                // Ir al detalle del activo seleccionado
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
            );
          },
        );
      },
    );
  }
}