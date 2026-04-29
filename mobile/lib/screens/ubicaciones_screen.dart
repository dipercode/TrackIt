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
  int _refreshCounter = 0; 

  @override
  void initState() {
    super.initState();
    _initFutures();
  }

  void _initFutures() {
    _dashboardFuture = ApiService.getActivos(estacionId: widget.estacionId);
  }

  void _refreshData() {
    setState(() {
      _refreshCounter++; 
      _initFutures();
    });
  }

  // Colores de estado (Semáforo)
  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF94A3B8);
    switch (estado.toUpperCase()) {
      case 'OPERATIVO': return const Color(0xFF4ADE80);
      case 'DISPONIBLE': return const Color(0xFF38BDF8);
      case 'REPARACIÓN':
      case 'CALIBRACIÓN': return const Color(0xFFFBBF24);
      case 'AVERIADO':
      case 'AVERIA':
      case 'BAJA': return const Color(0xFFFB7185);
      case 'TRASLADO': return const Color(0xFF818CF8);
      default: return const Color(0xFF38BDF8);
    }
  }

  Widget _buildDashboard() {
    return FutureBuilder<List<dynamic>>(
      key: ValueKey('db_$_refreshCounter'), 
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 124, child: Center(child: CircularProgressIndicator()));
        }

        final todosLosActivos = snapshot.data ?? [];
        final total = todosLosActivos.length;
        final operativos = todosLosActivos.where((a) => a['estado'].toString().toUpperCase() == 'OPERATIVO').length;
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

  Widget _cardInfo(String label, String valor, Color colorEstado) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          )
        ),
        child: Column(
          children: [
            Text(valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: colorEstado)),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                fontSize: 9, 
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1
              )
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          _buildDashboard(),
          
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
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surface,
                    labelStyle: TextStyle(
                      color: isSelected 
                        ? (isDark ? Colors.black : Colors.white) 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withValues(alpha: 0.1)
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
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
    final theme = Theme.of(context);
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
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Icon(Icons.layers_outlined, color: theme.colorScheme.primary),
                title: Text(
                  ubi['nombre'], 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)
                ),
                subtitle: Text(
                  "SALA ID: ${ubi['id']}", 
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 11)
                ),
                trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
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
    final theme = Theme.of(context);
    return FutureBuilder<List<dynamic>>(
      key: ValueKey('filtrados_$_refreshCounter'),
      future: ApiService.getActivos(estacionId: widget.estacionId, estado: estadoSeleccionado),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final activos = snapshot.data ?? [];
        if (activos.isEmpty) return Center(child: Text("SIN REGISTROS EN $estadoSeleccionado", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: activos.length,
          itemBuilder: (context, index) {
            final activo = activos[index];
            final color = _getEstadoColor(activo['estado']);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                leading: Icon(Icons.circle, color: color, size: 12),
                title: Text(activo['nombre'], style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                subtitle: Text(
                  activo['ubicacion_nombre']?.toUpperCase() ?? 'ALMACÉN', 
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))
                ),
                trailing: Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivoDetalleScreen(
                        activoId: activo['id'], 
                        activoNombre: activo['nombre']
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
}