import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activos_screen.dart';
import 'activo_detalle_screen.dart';

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
  String estadoSeleccionado = "TODOS";
  final List<String> categorias = ["TODOS", "OPERATIVO", "DISPONIBLE", "REPARACIÓN", "AVERIADO", "TRASLADO", "CALIBRACIÓN", "BAJA"];
  
  late Future<List<dynamic>> _dashboardFuture;
  int _refreshCounter = 0; // Para forzar el refresco físico del widget

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  void _initFutures() {
    // Obtenemos los activos para el Dashboard
    _dashboardFuture = ApiService.getActivos(estacionId: widget.estacionId);
  }

  void _refreshData() {
    setState(() {
      _refreshCounter++; // Al cambiar el contador, el Key del Dashboard cambiará
      _initFutures();
    });
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF94A3B8);
    switch (estado.toLowerCase()) {
      case 'operativo': return const Color(0xFF4ADE80);
      case 'disponible':
      case 'traslado': return const Color(0xFFFBBF24);
      case 'averiado':
      case 'averia':
      case 'reparación':
      case 'calibración':
      case 'baja': return const Color(0xFFFB7185);
      default: return const Color(0xFF38BDF8);
    }
  }

  Widget _buildDashboard() {
    return FutureBuilder<List<dynamic>>(
      // Usamos el Key para que Flutter sepa que debe resetear este widget
      key: ValueKey('dashboard_$_refreshCounter'), 
      future: _dashboardFuture,
      builder: (context, snapshot) {
        // Mientras carga o si hay error, manejamos el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 124, child: Center(child: CircularProgressIndicator()));
        }

        final todosLosActivos = snapshot.data ?? [];
        
        // CONTEO REAL DEL JSON
        final total = todosLosActivos.length;
        final operativos = todosLosActivos.where((a) => 
          a['estado'].toString().toUpperCase() == 'OPERATIVO'
        ).length;
        
        final incidencias = todosLosActivos.where((a) {
          final st = a['estado'].toString().toUpperCase();
          return st != 'OPERATIVO' && st != 'DISPONIBLE';
        }).length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _cardInfo("ACTIVOS", total.toString(), const Color(0xFF38BDF8)),
              _cardInfo("OPERATIVOS", operativos.toString(), const Color(0xFF4ADE80)),
              _cardInfo("INCIDENCIAS", incidencias.toString(), const Color(0xFFFB7185)),
            ],
          ),
        );
      },
    );
  }

  Widget _cardInfo(String label, String valor, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estacionNombre.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Llamamos al Dashboard que ahora tiene Key propio
          _buildDashboard(),
          
          // Selector de categorías (Chips)
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final isSelected = estadoSeleccionado == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        estadoSeleccionado = cat;
                      });
                    },
                    selectedColor: accentColor,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                // IMPORTANTE: El key aquí permite que la lista se refresque al cambiar de filtro
                key: ValueKey('$estadoSeleccionado$_refreshCounter'), 
                child: estadoSeleccionado == "TODOS"
                    ? _buildListaUbicaciones()
                    : _buildListaActivosFiltrados(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaUbicaciones() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getUbicaciones(widget.estacionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final ubicaciones = snapshot.data ?? [];
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ubicaciones.length,
          itemBuilder: (context, index) {
            final ubi = ubicaciones[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.layers_outlined, color: Color(0xFF38BDF8)),
                title: Text(ubi['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: Text("SALA ID: ${ubi['id']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivosScreen(
                        ubicacionId: ubi['id'],
                        ubicacionNombre: ubi['nombre'],
                      ),
                    ),
                  ).then((_) => _refreshData());
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListaActivosFiltrados() {
    return FutureBuilder<List<dynamic>>(
      // Aquí usamos el método directo porque depende del estadoSeleccionado (es dinámico)
      future: ApiService.getActivos(estacionId: widget.estacionId, estado: estadoSeleccionado),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final activos = snapshot.data ?? [];
        if (activos.isEmpty) return Center(child: Text("SIN REGISTROS EN $estadoSeleccionado", style: const TextStyle(color: Colors.white30)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: activos.length,
          itemBuilder: (context, index) {
            final activo = activos[index];
            final color = _getEstadoColor(activo['estado']);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(Icons.circle, color: color, size: 12),
                title: Text(activo['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(activo['ubicacion_nombre']?.toUpperCase() ?? 'ALMACÉN', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                trailing: const Icon(Icons.info_outline, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivoDetalleScreen(activoId: activo['id'], activoNombre: activo['nombre']),
                    ),
                  ).then((_) => _refreshData());
                },
              ),
            );
          },
        );
      },
    );
  }
}