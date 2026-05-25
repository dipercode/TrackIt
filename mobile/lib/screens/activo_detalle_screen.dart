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

  // COLORES CORPORATIVOS INTENSOS DE ALTO CONTRASTE (CORREGIDOS PARA FONDO CLARO)
  Color _getEstadoColor(String? estado) {
    if (estado == null) return const Color(0xFF64748B);
    switch (estado.toUpperCase()) {
      case 'OPERATIVO': return const Color(0xFF16A34A);   // Verde sólido vibrante
      case 'DISPONIBLE': return const Color(0xFF0284C7);  // Celeste fuerte legible
      case 'TRASLADO': return const Color(0xFF4F46E5);    // Índigo profundo
      case 'AVERIADO': return const Color(0xFFE11D48);    // Rojo / Rosa de advertencia
      case 'REPARACIÓN': return const Color(0xFFD97706);  // Ámbar / Dorado oscuro visible
      case 'CALIBRACIÓN': return const Color(0xFFC2410C); // Naranja quemado de alta definición
      case 'BAJA': return const Color(0xFF475569);        // Gris pizarra oscuro
      default: return const Color(0xFF0284C7);
    }
  }

  // MAPEADO DE ÍCONOS PARA LOS 7 ESTADOS
  IconData _getEstadoIcon(String estado) {
    switch (estado.toUpperCase()) {
      case 'OPERATIVO': return Icons.check_circle_rounded;
      case 'DISPONIBLE': return Icons.inventory_2_rounded;
      case 'TRASLADO': return Icons.local_shipping_rounded;
      case 'AVERIADO': return Icons.warning_rounded;
      case 'REPARACIÓN': return Icons.build_circle_rounded;
      case 'CALIBRACIÓN': return Icons.analytics_rounded;
      case 'BAJA': return Icons.money_off_rounded;
      default: return Icons.help_center_rounded;
    }
  }

  void _mostrarModalQR(Map<String, dynamic> data, BuildContext pantallaContext) {
    final theme = Theme.of(context);
    if (data['qr_imagen'] == null) return;

    final String urlFinal = data['qr_imagen'].toString().startsWith('http')
        ? data['qr_imagen']
        : "${ApiService.mediaUrl}${data['qr_imagen']}";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 25,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['nombre'].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Image.network(
                  urlFinal,
                  height: 260,
                  width: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 260,
                      width: 260,
                      child: Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                data['codigo_qr'] ?? "TRACKIT-N/A",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "ID de control de inventario seguro",
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(pantallaContext).showSnackBar(
                    const SnackBar(
                      content: Text("Enviando código QR a la impresora térmica..."),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text("IMPRIMIR ETIQUETA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LISTADO EXCLUSIVO CON LOS 6 ESTADOS ASIGNABLES MANUALMENTE
  Widget _buildSeccionAccionesRapidas(Map<String, dynamic> activo) {
    final theme = Theme.of(context);
    
    final todosLosEstados = [
      'OPERATIVO',
      'DISPONIBLE',
      'AVERIADO',
      'REPARACIÓN',
      'CALIBRACIÓN',
      'BAJA'
    ];

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
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: todosLosEstados.length,
            separatorBuilder: (context, index) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final estado = todosLosEstados[index];
              final color = _getEstadoColor(estado);
              final icono = _getEstadoIcon(estado);
              final bool esEstadoActual = activo['estado'].toString().toUpperCase() == estado;

              return _botonEstadoItem(activo, estado, color, icono, esEstadoActual);
            },
          ),
        ),
      ],
    );
  }

  // Botones cambios de estado de alto contraste.
  Widget _botonEstadoItem(Map<String, dynamic> activo, String estado, Color color, IconData icono, bool esActual) {
    return InkWell(
      onTap: esActual ? null : () async {
        // 1. Actualizamos el estado principal en la base de datos
        bool okEstado = await ApiService.actualizarEstadoActivo(activo['id'], estado);
        
        if (okEstado) {
          // 2. Insertamos el registro en el historial para que quede constancia del cambio.
          // Como no se mueve físicamente, el destino es su ubicación actual ('ubicacion').
          await ApiService.registrarMovimiento(
            activo['id'],
            activo['ubicacion'], // Se queda en el mismo lugar
            estado,              // Guarda el nuevo estado como tipo de movimiento ("AVERIADO", "OPERATIVO", etc.)
            "Cambio de estado manual desde la ficha del activo", // Motivo automático
          );

          if (!mounted) return;
          _refreshData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Estado actualizado a $estado con éxito"), 
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
            )
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error al intentar actualizar el estado"), 
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            )
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: esActual ? 1.0 : 0.75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esActual ? color : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: esActual ? 2.5 : 1.2),
                boxShadow: esActual ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4)
                  )
                ] : null,
              ),
              child: Icon(
                icono, 
                color: esActual ? Colors.white : color,
                size: 22
              ),
            ),
            const SizedBox(height: 6),
            Text(
              estado, 
              style: TextStyle(
                fontSize: 10, 
                fontWeight: esActual ? FontWeight.w900 : FontWeight.w800,
                color: color,
              )
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDialogoTransferencia() {
    int? estacionSeleccionadaId;
    int? ubicacionId;
    List<dynamic> estaciones = [];
    List<dynamic> ubicaciones = [];
    bool cargandoUbicaciones = false;

    final motivoController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text(
              "REGISTRAR TRANSFERENCIA",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 5),
                    FutureBuilder<List<dynamic>>(
                      future: estaciones.isEmpty ? ApiService.getEstaciones() : Future.value(estaciones),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && estaciones.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: LinearProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData && estaciones.isEmpty) {
                          estaciones = snapshot.data!;
                        }

                        return DropdownButtonFormField<int>(
                          initialValue: estacionSeleccionadaId,
                          isExpanded: true, 
                          decoration: const InputDecoration(
                            labelText: "Estación Destino",
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          ),
                          items: estaciones.map((e) => DropdownMenuItem<int>(
                            value: e['id'],
                            child: Text(e['nombre'].toString().toUpperCase(), overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (value) async {
                            if (value == estacionSeleccionadaId) return;
                            
                            setDialogState(() {
                              estacionSeleccionadaId = value;
                              ubicacionId = null;
                              ubicaciones = [];
                              cargandoUbicaciones = true;
                            });

                            try {
                              List<dynamic> data = await ApiService.getUbicaciones(value!);
                              setDialogState(() {
                                ubicaciones = data;
                                cargandoUbicaciones = false;
                              });
                            } catch (e) {
                              setDialogState(() { cargandoUbicaciones = false; });
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    if (cargandoUbicaciones)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: CircularProgressIndicator(),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: ubicacionId,
                        isExpanded: true,
                        onChanged: estacionSeleccionadaId == null 
                            ? null 
                            : (value) => setDialogState(() => ubicacionId = value),
                        hint: Text(
                          estacionSeleccionadaId == null 
                              ? "Selecciona una estación primero" 
                              : "Ubicación exacta destino",
                          style: const TextStyle(fontSize: 13), 
                          overflow: TextOverflow.ellipsis,
                        ),
                        decoration: InputDecoration(
                          labelText: estacionSeleccionadaId == null 
                              ? "Estación requerida" 
                              : "Ubicación Destino", 
                          prefixIcon: const Icon(Icons.location_on, size: 20),
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        ),
                        items: ubicaciones.isEmpty && estacionSeleccionadaId != null
                            ? [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text("SIN UBICACIONES", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                )
                              ]
                            : ubicaciones.map((u) => DropdownMenuItem<int>(
                                value: u['id'],
                                child: Text(u['nombre'].toString().toUpperCase(), style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                              )).toList(),
                      ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: motivoController,
                      maxLines: 2, 
                      decoration: const InputDecoration(
                        labelText: "Motivo del traslado",
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: (ubicacionId == null) 
                    ? null 
                    : () async {
                        bool ok = await ApiService.registrarMovimiento(
                          widget.activoId,
                          ubicacionId!,
                          "TRASLADO",
                          motivoController.text.trim(),
                        );

                        if (!dialogContext.mounted) return;

                        if (ok) {
                          Navigator.of(dialogContext).pop();
                          _refreshData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Transferencia registrada con éxito"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                child: const Text("CONFIRMAR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
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
          InkWell(
            onTap: () => _mostrarModalQR(data, context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
              child: _infoRow(
                Icons.qr_code_2, 
                "CÓDIGO DE CONTROL (PULSA PARA VER QR)", 
                (data['codigo_qr'] ?? "VER QR").toString(), 
                theme.colorScheme.primary
              ),
            ),
          ),
          Divider(height: 30, color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
          _infoRow(Icons.fingerprint, "IDENTIFICADOR INTERNO", "#${data['id']}", null),
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
              leading: Icon(_getEstadoIcon(mov['tipo']), color: color),
              title: Text("${mov['ubicacion_origen_nombre'] ?? 'Origen'} → ${mov['ubicacion_destino_nombre'] ?? 'Destino'}"),
              subtitle: Text(mov['fecha'] ?? ''),
              trailing: Text(
                mov['tipo'].toString().toUpperCase(), 
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)
              ),
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
              Text(value, style: TextStyle(color: color ?? theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 9)),
            ],
          ),
        ),
      ],
    );
  }
}