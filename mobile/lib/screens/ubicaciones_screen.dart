import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activos_screen.dart';
import 'activo_detalle_screen.dart'; // Para ir al detalle directamente desde el filtro

class UbicacionesScreen extends StatefulWidget {
  final int estacionId;
  final String estacionNombre;

  const UbicacionesScreen({
    super.key,
    required this.estacionId,
    required this.estacionNombre,
  });

  @override
  State<UbicacionesScreen> createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  // Estado del filtro
  String estadoSeleccionado = "TODOS";
  final List<String> categorias = ["TODOS", "OPERATIVO", "DISPONIBLE", "REPARACIÓN", "AVERIADO", "TRASLADO", "CALIBRACIÓN", "BAJA"];

  // Colores para los activos cuando se muestran en la lista filtrada
  Color _getEstadoColor(String? estado) {
    if (estado == null) return Colors.grey;
    switch (estado.toLowerCase()) {
      case 'operativo':
        return Colors.green;
      case 'disponible':
      case 'traslado':
        return Colors.orange;
      case 'averiado':
      case 'averia':
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
        title: Text(widget.estacionNombre),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // BARRA DE FILTROS GLOBAL
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final isSelected = estadoSeleccionado == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.blueGrey,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        estadoSeleccionado = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // CONTENIDO DINÁMICO
          Expanded(
            child: estadoSeleccionado == "TODOS"
                ? _buildListaUbicaciones() // Vista original
                : _buildListaActivosFiltrados(), // Vista global de activos
          ),
        ],
      ),
    );
  }

  // 1. Muestra las Ubicaciones (Carpetas) de la estación
  Widget _buildListaUbicaciones() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getUbicaciones(widget.estacionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final ubicaciones = snapshot.data ?? [];
        if (ubicaciones.isEmpty) {
          return const Center(child: Text("No hay ubicaciones creadas"));
        }

        return ListView.builder(
          itemCount: ubicaciones.length,
          itemBuilder: (context, index) {
            final ubi = ubicaciones[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.place, color: Colors.blueGrey),
                title: Text(ubi['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("ID: ${ubi['id']}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
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
              ),
            );
          },
        );
      },
    );
  }

  // 2. Muestra TODOS los activos de la estación que coincidan con el filtro
  Widget _buildListaActivosFiltrados() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getActivos(
        estacionId: widget.estacionId,
        estado: estadoSeleccionado,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final activos = snapshot.data ?? [];
        if (activos.isEmpty) {
          return Center(
            child: Text("No hay activos con estado $estadoSeleccionado en esta sede"),
          );
        }

        return ListView.builder(
          itemCount: activos.length,
          itemBuilder: (context, index) {
            final activo = activos[index];
            final Color colorEstado = _getEstadoColor(activo['estado']);

            return ListTile(
              leading: Icon(Icons.inventory_2, color: colorEstado),
              title: Text(activo['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Ubicación: ${activo['ubicacion_nombre'] ?? 'Desconocida'}"),
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
            );
          },
        );
      },
    );
  }
}