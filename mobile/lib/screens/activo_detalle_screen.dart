import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'activo_form_screen.dart';

class ActivoDetalleScreen extends StatefulWidget {
  final int activoId;
  final String activoNombre;

  const ActivoDetalleScreen({super.key, required this.activoId, required this.activoNombre});

  @override
  State<ActivoDetalleScreen> createState() => _ActivoDetalleScreenState();
}

class _ActivoDetalleScreenState extends State<ActivoDetalleScreen> {
  int _refreshKey = 0;

  void _refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF94A3B8);
    switch (estado.toUpperCase()) {
      case 'OPERATIVO': return const Color(0xFF4ADE80);
      case 'DISPONIBLE': return const Color(0xFF38BDF8);
      case 'REPARACIÓN':
      case 'CALIBRACIÓN': return const Color(0xFFFBBF24);
      case 'AVERIADO':
      case 'BAJA': return const Color(0xFFFB7185);
      case 'TRASLADO': return const Color(0xFF818CF8);
      default: return const Color(0xFF38BDF8);
    }
  }

  Widget _buildSeccionAccionesRapidas(Map<String, dynamic> activo) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bolt, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text("CAMBIAR ESTADO", 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.5, 
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5)
              )
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _botonEstadoItem(activo, "OPERATIVO", const Color(0xFF4ADE80), Icons.check_circle),
            _botonEstadoItem(activo, "AVERIADO", const Color(0xFFFB7185), Icons.warning_rounded),
            _botonEstadoItem(activo, "REPARACIÓN", const Color(0xFFFBBF24), Icons.build_circle),
            _botonEstadoItem(activo, "BAJA", Colors.grey, Icons.not_interested),
          ],
        ),
      ],
    );
  }

  Widget _botonEstadoItem(Map<String, dynamic> activo, String estado, Color color, IconData icono) {
    return InkWell(
      onTap: () async {
        bool ok = await ApiService.actualizarEstadoActivo(activo['id'], estado);
        if (!mounted) return;
        if (ok) {
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Estado actualizado a $estado"), backgroundColor: color)
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2))
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(estado, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _abrirDialogoTransferencia() {
    int? ubicacionId;
    final motivoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("REGISTRAR TRANSFERENCIA", 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<List<dynamic>>(
              future: ApiService.getTodasLasUbicaciones(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text("No hay ubicaciones");
                
                return DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: "Ubicación Destino", border: OutlineInputBorder()),
                  items: snapshot.data!.map((u) => DropdownMenuItem<int>(
                    value: u['id'], child: Text(u['nombre'].toString().toUpperCase()),
                  )).toList(),
                  onChanged: (value) => ubicacionId = value,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(labelText: "Motivo", border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text("CANCELAR")
          ),
          ElevatedButton(
            onPressed: () async {
              if (ubicacionId == null) return;
              
              bool ok = await ApiService.registrarMovimiento(
                widget.activoId, 
                ubicacionId!, 
                "TRASLADO", 
                motivoController.text
              );
              
              if (!dialogContext.mounted) return;
              
              if (ok) {
                Navigator.of(dialogContext).pop();
                _refreshData();
              }
            },
            child: const Text("CONFIRMAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activoNombre.toUpperCase()),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.tune, color: accentColor),
            onSelected: (value) async {
              if (value == 'refresh') {
                _refreshData();
              } else if (value == 'edit') {
                final navigator = Navigator.of(context);
                final datos = await ApiService.obtenerActivo(widget.activoId);
                
                if (!mounted || datos == null) return;
                
                final res = await navigator.push(
                  MaterialPageRoute(
                    builder: (context) => ActivoFormScreen(
                      ubicacionId: datos['ubicacion'],
                      ubicacionNombre: datos['ubicacion_nombre'] ?? 'N/A',
                      activoParaEditar: datos,
                    ),
                  ),
                );
                if (res == true) _refreshData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text("Actualizar datos")),
              const PopupMenuItem(value: 'edit', child: Text("Editar Activo")),
            ],
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        key: ValueKey('main_future_$_refreshKey'),
        future: ApiService.obtenerActivo(widget.activoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text("Error al cargar datos"));

          final activo = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(activo),
                const SizedBox(height: 30),
                _buildSeccionAccionesRapidas(activo),
                const SizedBox(height: 35),
                Row(
                  children: [
                    Icon(Icons.history, size: 18, color: accentColor),
                    const SizedBox(width: 8),
                    const Text("HISTORIAL DE MOVIMIENTOS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 15),
                _buildMovimientosList(),
              ],
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirDialogoTransferencia,
        label: const Text("TRANSFERIR", style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.move_up),
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final Color colorEstado = _getEstadoColor(data['estado']);
    
    // Lógica para detectar si la revisión está vencida
    bool isVencido = false;
    String fechaRevision = data['fecha_proxima_verificacion'] ?? "No programada";
    
    if (data['fecha_proxima_verificacion'] != null) {
      try {
        DateTime fecha = DateTime.parse(data['fecha_proxima_verificacion']);
        if (fecha.isBefore(DateTime.now())) {
          isVencido = true;
        }
      } catch (e) {
        debugPrint("Error parseando fecha: $e");
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _infoRow(Icons.fingerprint, "IDENTIFICADOR", "#${data['id']}", null),
          Divider(height: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          _infoRow(Icons.location_on_outlined, "UBICACIÓN ACTUAL", (data['ubicacion_nombre'] ?? "N/A").toString().toUpperCase(), null),
          Divider(height: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          _infoRow(Icons.bolt, "ESTADO ACTUAL", data['estado'].toString().toUpperCase(), colorEstado),
          Divider(height: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          _infoRow(
            Icons.event_available, 
            "PRÓXIMA REVISIÓN / CALIBRACIÓN", 
            fechaRevision, 
            isVencido ? const Color(0xFFFB7185) : null
          ),
          Divider(height: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          _infoRow(Icons.notes, "DESCRIPCIÓN", data['descripcion'] ?? "Sin detalles.", null),
        ],
      ),
    );
  }

  IconData _getMovimientoIcon(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'OPERATIVO': return Icons.check_circle_outline;
      case 'DISPONIBLE': return Icons.inventory_2_outlined;
      case 'REPARACIÓN': return Icons.build_circle_outlined;
      case 'TRASLADO': return Icons.local_shipping_outlined;
      case 'BAJA': return Icons.delete_sweep_outlined;
      default: return Icons.history;
    }
  }

  Widget _buildMovimientosList() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getMovimientosActivo(widget.activoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
        final movimientos = snapshot.data ?? [];
        if (movimientos.isEmpty) return const Text("Sin registros previos.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final mov = movimientos[index];
            final color = _getEstadoColor(mov['tipo']);
            return ListTile(
              leading: Icon(_getMovimientoIcon(mov['tipo']), color: color),
              title: Text("${mov['ubicacion_origen_nombre'] ?? 'Origen'} → ${mov['ubicacion_destino_nombre'] ?? 'Destino'}"),
              subtitle: Text(mov['fecha'] ?? ''),
              trailing: Text(mov['tipo'], style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color? color) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 9)),
              Text(value, style: TextStyle(color: color ?? theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}