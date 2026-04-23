import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActivoDetalleScreen extends StatefulWidget {
  final int activoId;
  final String activoNombre;

  const ActivoDetalleScreen({super.key, required this.activoId, required this.activoNombre});

  @override
  State<ActivoDetalleScreen> createState() => _ActivoDetalleScreenState();
}

class _ActivoDetalleScreenState extends State<ActivoDetalleScreen> {
  
  void _refreshData() => setState(() {});

  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF94A3B8);
    switch (estado.toUpperCase()) {
      case 'OPERATIVO': return const Color(0xFF4ADE80);
      case 'AVERIADO':
      case 'AVERIA':
      case 'BAJA': return const Color(0xFFFB7185);
      case 'REPARACIÓN':
      case 'CALIBRACIÓN': return const Color(0xFFFBBF24);
      default: return const Color(0xFF38BDF8);
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    bool ok = await ApiService.actualizarEstadoActivo(widget.activoId, nuevoEstado);
    if (ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("ESTADO ACTUALIZADO: $nuevoEstado"),
        backgroundColor: _getEstadoColor(nuevoEstado).withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
      ));
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activoNombre.toUpperCase()),
        actions: [
          // MENÚ DE ACCIONES REPARADO Y ESTILIZADO
          PopupMenuButton<String>(
            icon: Icon(Icons.tune, color: accentColor),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onSelected: (value) {
              if (value == 'refresh') {
                _refreshData();
              } else {
                _cambiarEstado(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18, color: accentColor),
                    const SizedBox(width: 12),
                    const Text("Actualizar Todo", style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 10),
              _buildMenuItem('OPERATIVO', 'Operativo', const Color(0xFF4ADE80)),
              _buildMenuItem('DISPONIBLE', 'Disponible', const Color(0xFF38BDF8)),
              _buildMenuItem('REPARACIÓN', 'En Reparación', const Color(0xFFFBBF24)),
              _buildMenuItem('AVERIADO', 'Avería', const Color(0xFFFB7185)),
              _buildMenuItem('BAJA', 'Dar de Baja', Colors.white30),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 35),
            Row(
              children: [
                Icon(Icons.history, size: 18, color: accentColor),
                const SizedBox(width: 8),
                const Text("HISTORIAL DE MOVIMIENTOS", 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white60)),
              ],
            ),
            const SizedBox(height: 15),
            _buildMovimientosList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioMovimiento(context),
        label: const Text("TRANSFERIR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        icon: const Icon(Icons.move_up),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String val, String text, Color color) {
    return PopupMenuItem(
      value: val,
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getActivoDetalle(widget.activoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final data = snapshot.data!;
        final Color colorEstado = _getEstadoColor(data['estado']);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorEstado.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _infoRow(Icons.fingerprint, "IDENTIFICADOR", "#${data['id']}", null),
              const Divider(height: 30, color: Colors.white10),
              _infoRow(Icons.bolt, "ESTADO ACTUAL", data['estado'].toString().toUpperCase(), colorEstado),
              const Divider(height: 30, color: Colors.white10),
              _infoRow(Icons.notes, "DESCRIPCIÓN", data['descripcion'] ?? "Sin detalles adicionales registrados.", null),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMovimientosList() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getMovimientosActivo(widget.activoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox();
        final movimientos = snapshot.data ?? [];
        if (movimientos.isEmpty) return const Text("SIN REGISTROS PREVIOS", style: TextStyle(color: Colors.white24, fontSize: 11));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final mov = movimientos[index];
            final color = _getEstadoColor(mov['tipo']);
            
            return IntrinsicHeight(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle, 
                          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]),
                      ),
                      Expanded(child: Container(width: 2, color: Colors.white10)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(mov['tipo'], style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                              Text(mov['fecha'].toString().substring(0, 10), style: const TextStyle(color: Colors.white24, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("${mov['ubicacion_origen_nombre']} → ${mov['ubicacion_destino_nombre']}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (mov['motivo'] != null && mov['motivo'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(mov['motivo'], style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color? color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color ?? Colors.white38),
        const SizedBox(width: 15),
        Expanded( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)
              ),
              Text(
                value, 
                style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                softWrap: true, 
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _mostrarFormularioMovimiento(BuildContext context) {
    int? seleccionadaId;
    String seleccionTipo = 'TRASLADO'; 
    final TextEditingController motivoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            left: 25, right: 25, top: 15
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              const Text("NUEVA TRANSFERENCIA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 25),
              
              FutureBuilder<List<dynamic>>(
                future: ApiService.getTodasLasUbicaciones(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return DropdownButtonFormField<int>(
                    dropdownColor: const Color(0xFF1E293B),
                    decoration: const InputDecoration(labelText: "UBICACIÓN DESTINO", filled: true, fillColor: Color(0xFF1E293B)),
                    items: snapshot.data!.map((ubi) => DropdownMenuItem<int>(
                      value: ubi['id'], child: Text(ubi['nombre'], style: const TextStyle(color: Colors.white))
                    )).toList(),
                    onChanged: (val) => seleccionadaId = val,
                  );
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: seleccionTipo,
                dropdownColor: const Color(0xFF1E293B),
                decoration: const InputDecoration(labelText: "TIPO DE MOVIMIENTO", filled: true, fillColor: Color(0xFF1E293B)),
                items: const [
                  DropdownMenuItem(value: 'TRASLADO', child: Text("TRASLADO", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'REPARACIÓN', child: Text("REPARACIÓN", style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'CALIBRACIÓN', child: Text("CALIBRACIÓN", style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) => setModalState(() => seleccionTipo = val!),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: motivoController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "MOTIVO / NOTAS", filled: true, fillColor: Color(0xFF1E293B)),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (seleccionadaId != null) {
                      bool ok = await ApiService.registrarMovimiento(
                        widget.activoId, seleccionadaId!, seleccionTipo, motivoController.text);
                      if (ok && context.mounted) {
                        Navigator.pop(context);
                        _refreshData();
                      }
                    }
                  },
                  child: const Text("CONFIRMAR TRANSFERENCIA", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}