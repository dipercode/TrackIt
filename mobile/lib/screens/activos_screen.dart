import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activo_detalle_screen.dart';
import 'qr_scanner_screen.dart';
import 'activo_form_screen.dart';

class ActivosScreen extends StatefulWidget {
  final int ubicacionId;
  final String ubicacionNombre;

  const ActivosScreen({super.key, required this.ubicacionId, required this.ubicacionNombre});

  @override
  State<ActivosScreen> createState() => _ActivosScreenState();
}

class _ActivosScreenState extends State<ActivosScreen> {
  String estadoSeleccionado = "TODOS";
  final List<String> categorias = ["TODOS", "OPERATIVO", "DISPONIBLE", "REPARACIÓN", "AVERIADO", "TRASLADO", "CALIBRACIÓN", "BAJA"];

  void _refreshData() {
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ubicacionNombre.toUpperCase()),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: theme.colorScheme.surface,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshData();
              } else if (value == 'add') {
                _irAFomulario();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18, color: accentColor),
                    const SizedBox(width: 12),
                    Text("Actualizar Lista", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add_box_outlined, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Text("Nuevo Activo", style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // BARRA DE FILTROS (ChoiceChips adaptativos)
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
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
                    onSelected: (selected) => setState(() => estadoSeleccionado = cat),
                    selectedColor: accentColor,
                    backgroundColor: theme.colorScheme.surface,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected 
                        ? (isDark ? Colors.black : Colors.white) 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), 
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : theme.colorScheme.onSurface.withValues(alpha: 0.1)
                      )
                    ),
                  ),
                );
              },
            ),
          ),
          
          // LISTADO DE ACTIVOS
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.getActivos(
                ubicacionId: widget.ubicacionId,
                estado: estadoSeleccionado == "TODOS" ? null : estadoSeleccionado,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3))));
                }
                final activos = snapshot.data ?? [];
                if (activos.isEmpty) {
                  return Center(
                    child: Text("NO HAY REGISTROS", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3), letterSpacing: 2)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: activos.length,
                  itemBuilder: (context, index) {
                    final activo = activos[index];
                    final String estado = activo['estado'] ?? 'Sin asignar';
                    final Color colorEstado = _getEstadoColor(estado);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 4,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colorEstado,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        title: Text(
                          activo["nombre"],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface),
                        ),
                        subtitle: Text(
                          estado.toUpperCase(),
                          style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivoDetalleScreen(
                                activoId: activo['id'],
                                activoNombre: activo['nombre'],
                              ),
                            ),
                          ).then((_) => _refreshData());
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAFomulario,
        label: const Text("AÑADIR ACTIVO", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Future<void> _irAFomulario() async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivoFormScreen(
          ubicacionId: widget.ubicacionId,
          ubicacionNombre: widget.ubicacionNombre,
        ),
      ),
    );
    if (result == true && mounted) _refreshData();
  }
}