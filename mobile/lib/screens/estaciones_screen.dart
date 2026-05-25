import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'ubicaciones_screen.dart';
import 'qr_scanner_screen.dart';
import 'activo_search_delegate.dart';
import 'activo_detalle_screen.dart';

class EstacionesScreen extends StatefulWidget {
  const EstacionesScreen({super.key});

  @override
  State<EstacionesScreen> createState() => _EstacionesScreenState();
}

class _EstacionesScreenState extends State<EstacionesScreen> {
  late Future<List<dynamic>> estaciones;

  @override
  void initState() {
    super.initState();
    _refreshEstaciones();
  }

  void _refreshEstaciones() {
    setState(() {
      estaciones = ApiService.getEstaciones();
    });
  }

  // MÉTODO PARA CERRAR SESIÓN
  void _handleLogout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("CERRAR SESIÓN"),
        content: const Text("¿Estás seguro de que deseas salir de la aplicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SALIR", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await AuthService.logout();
      if (!mounted) return;
      
      // Navegar al login eliminando el historial para que no pueda volver atrás
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Widget de Alerta de Urgencias (ROJO)
  Widget _buildSeccionUrgencias() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getActivosUrgentes(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(); 
        }

        // Normalizamos la fecha actual a las 00:00:00 de hoy
        final hoy = DateTime.now();
        final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);

        final vencidos = snapshot.data!.where((a) {
          if (a['fecha_proxima_verificacion'] == null) return false;
          try {
            final fecha = DateTime.parse(a['fecha_proxima_verificacion'].toString());
            final soloFechaActivo = DateTime(fecha.year, fecha.month, fecha.day);
            
            // Es estrictamente anterior a hoy
            return soloFechaActivo.isBefore(soloHoy);
          } catch (_) {
            return false;
          }
        }).toList();

        if (vencidos.isEmpty) return const SizedBox();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2), // Fondo rojo/rosa sólido muy claro (Alto contraste)
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECDD3)), // Borde definido
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 20), // Icono más visible
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "URGENTE: ${vencidos.length} activos vencidos",
                      style: const TextStyle(
                        color: Color(0xFF9F1239), // Texto oscuro de alta legibilidad
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      "Calibración expirada. Requiere atención inmediata.",
                      style: TextStyle(
                        color: Color(0xFFBE123C), // Subtexto complementario oscuro
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_circle_right_outlined, color: Color(0xFFE11D48)),
                onPressed: () => _mostrarDetalleUrgencias(vencidos, "ACTIVOS VENCIDOS", const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
              )
            ],
          ),
        );
      },
    );
  }

  // WIDGET DE ALERTA DE PREVENCIÓN (ÁMBAR - PRÓXIMOS 15 DÍAS)
  Widget _buildSeccionProximos() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getActivosProximos(), 
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
        }

        final hoy = DateTime.now();
        final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
        final limiteProximo = soloHoy.add(const Duration(days: 15));

        final proximos = snapshot.data!.where((a) {
          if (a['fecha_proxima_verificacion'] == null) return false;
          try {
            final fecha = DateTime.parse(a['fecha_proxima_verificacion'].toString());
            final soloFechaActivo = DateTime(fecha.year, fecha.month, fecha.day);
            
            // Debe ser HOY o en los próximos 15 días (inclusive el día límite)
            return (soloFechaActivo.isAtSameMomentAs(soloHoy) || soloFechaActivo.isAfter(soloHoy)) 
                && (soloFechaActivo.isBefore(limiteProximo) || soloFechaActivo.isAtSameMomentAs(limiteProximo));
          } catch (_) {
            return false;
          }
        }).toList();

        if (proximos.isEmpty) return const SizedBox();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PREVENCIÓN: ${proximos.length} por caducar",
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                  ),
                ),
                    const Text(
                      "Calibración requerida en los próximos 15 días.",
                      style: TextStyle(
                        color: Color(0xFFC2410C),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_circle_right_outlined, color: Color(0xFFD97706)),
                onPressed: () => _mostrarDetalleUrgencias(proximos, "PRÓXIMOS A VENCER (15 DÍAS)", const Color(0xFFFFE9D6), Color(0xFFD97706)),
              )
            ],
          ),
        );
      },
    );
  }

  // Muestra el detalle de activos urgentes en un modal bottom sheet
  void _mostrarDetalleUrgencias(List<dynamic> activos, String titulo, Color avatarBg, Color mainColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titulo, 
              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)
            ),
            const SizedBox(height: 10),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activos.length,
                itemBuilder: (context, index) {
                  final a = activos[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: avatarBg,
                      child: Icon(Icons.priority_high, color: mainColor, size: 18),
                    ),
                    title: Text(
                      a['nombre'].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      "Fecha límite: ${a['fecha_proxima_verificacion'] ?? 'Sin fecha'}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivoDetalleScreen(
                            activoId: a['id'],
                            activoNombre: a['nombre'],
                          ),
                        ),
                      ).then((_) => _refreshEstaciones());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarFormEstacion() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("NUEVA ESTACIÓN"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: "NOMBRE DE LA ESTACIÓN",
            hintText: "Ej: SEDE CENTRAL",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                bool ok = await ApiService.crearEstacion(controller.text.trim());
                if (ok && mounted) {
                  navigator.pop();
                  _refreshEstaciones();
                }
              }
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRACKIT"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: ActivoSearchDelegate()),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScannerScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _handleLogout,
            tooltip: "Cerrar Sesión",
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormEstacion,
        tooltip: "Añadir Estación",
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚨 ALERTA 1: VENCIDOS (Crítico)
          _buildSeccionUrgencias(),
          
          // ⚠️ ALERTA 2: PRÓXIMOS (Advertencia preventiva)
          _buildSeccionProximos(),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text("ESTACIONES", 
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.grey)),
          ),
          
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: estaciones,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error al conectar con el servidor"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay estaciones registradas"));
                }

                final listaEstaciones = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: listaEstaciones.length,
                  itemBuilder: (context, index) {
                    final estacion = listaEstaciones[index];
                    return _buildCardEstacion(estacion, accentColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEstacion(dynamic estacion, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UbicacionesScreen(
                  estacionId: estacion["id"],
                  estacionNombre: estacion["nombre"],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.business_center, color: accentColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estacion["nombre"].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estacion["direccion"] ?? "Sin ubicación asignada",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}