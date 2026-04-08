
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
  
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activoNombre),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Información General", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildInfoCard(),
            const SizedBox(height: 25),
            const Text("Historial de Movimientos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildMovimientosList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioMovimiento(context),
        label: const Text("Mover Activo"),
        icon: const Icon(Icons.transfer_within_a_station),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _mostrarFormularioMovimiento(BuildContext context) {
    int? seleccionadaId;
    String seleccionTipo = 'TRASLADO'; 
    final TextEditingController motivoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder( // Necesario para que el dropdown de tipo se actualice visualmente
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Registrar Movimiento", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              FutureBuilder<List<dynamic>>(
                future: ApiService.getTodasLasUbicaciones(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: "Ubicación Destino", border: OutlineInputBorder()),
                    items: snapshot.data!.map((ubi) => DropdownMenuItem<int>(
                      value: ubi['id'], child: Text(ubi['nombre'])
                    )).toList(),
                    onChanged: (val) => seleccionadaId = val,
                  );
                },
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: seleccionTipo,
                decoration: const InputDecoration(labelText: "Tipo de Movimiento", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'TRASLADO', child: Text("Traslado Ordinario")),
                  DropdownMenuItem(value: 'AVERIADO', child: Text("Envío a Avería")),
                  DropdownMenuItem(value: 'REPARACIÓN', child: Text("Entrada en Reparación")),
                  DropdownMenuItem(value: 'CALIBRACIÓN', child: Text("Calibración")),
                ],
                onChanged: (val) {
                  setModalState(() => seleccionTipo = val!);
                },
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: motivoController,
                decoration: const InputDecoration(
                  labelText: "Motivo / Observaciones",
                  border: OutlineInputBorder(),
                  hintText: "Ej: Pantalla rota, cambio de oficina..."
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  onPressed: () async {
                    if (seleccionadaId != null) {
                      bool ok = await ApiService.registrarMovimiento(
                        widget.activoId, 
                        seleccionadaId!, 
                        seleccionTipo,
                        motivoController.text
                      );
                      
                      // Validación de seguridad para async gaps
                      if (!mounted) return;

                      if (ok) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Registrado")));
                        _refreshData(); 
                      }
                    }
                  },
                  child: const Text("CONFIRMAR", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getActivoDetalle(widget.activoId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _infoRow(Icons.tag, "ID", data['id'].toString()),
                _infoRow(Icons.info_outline, "Estado", data['estado']),
                _infoRow(Icons.description, "Descripción", data['descripcion'] ?? "Sin descripción"),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovimientosList() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getMovimientosActivo(widget.activoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        final movimientos = snapshot.data ?? [];
        if (movimientos.isEmpty) return const Text("No hay movimientos registrados.");

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movimientos.length,
          itemBuilder: (context, index) {
            final mov = movimientos[index];
            
            Color colorEtiqueta = Colors.blue.shade700;
            if (mov['tipo'] == 'AVERIADO' || mov['tipo'] == 'BAJA') colorEtiqueta = Colors.red.shade700;
            if (mov['tipo'] == 'REPARACIÓN' || mov['tipo'] == 'CALIBRACIÓN') colorEtiqueta = Colors.orange.shade800;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.blueGrey),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        // Corrección: withValues en lugar de withOpacity
                        color: colorEtiqueta.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colorEtiqueta),
                      ),
                      child: Text(
                        mov['tipo'] ?? 'TRASLADO',
                        style: TextStyle(
                          fontSize: 11, 
                          fontWeight: FontWeight.bold, 
                          color: colorEtiqueta
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Destino: ${mov['ubicacion_destino_nombre'] ?? 'N/A'}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Origen: ${mov['ubicacion_origen_nombre'] ?? 'N/A'}", style: const TextStyle(fontSize: 13)),
                      Text("Fecha: ${mov['fecha'].toString().substring(0, 10)}", style: const TextStyle(fontSize: 12)),
                      
                      if (mov['motivo'] != null && mov['motivo'].toString().isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            // Corrección: Border lateral izquierdo en lugar de leftBar
                            border: Border(
                              left: BorderSide(color: colorEtiqueta, width: 3),
                            ),
                          ),
                          child: Text(
                            "Motivo: ${mov['motivo']}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                              fontSize: 13
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}