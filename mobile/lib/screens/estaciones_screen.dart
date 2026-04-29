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

  // Widget de Alerta de Urgencias
  Widget _buildSeccionUrgencias() {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getActivosUrgentes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("ERROR EN BANNER: ${snapshot.error}");
          return const SizedBox(); 
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(); 
        }

        final cantidad = snapshot.data!.length;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFB7185).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFB7185).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFB7185), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "URGENTE: $cantidad activos vencidos",
                  style: const TextStyle(
                    color: Color(0xFFFB7185),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_circle_right_outlined, color: Color(0xFFFB7185)),
                onPressed: () => _mostrarDetalleUrgencias(snapshot.data!),
              )
            ],
          ),
        );
      },
    );
  }

  void _mostrarDetalleUrgencias(List<dynamic> activos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ACTIVOS VENCIDOS", 
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 14)
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
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFE4E6),
                      child: Icon(Icons.priority_high, color: Color(0xFFFB7185), size: 18),
                    ),
                    title: Text(
                      a['nombre'].toString().toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      "Venció: ${a['fecha_proxima_verificacion'] ?? 'Sin fecha'}",
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
          // BOTÓN DE CERRAR SESIÓN AÑADIDO
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
          _buildSeccionUrgencias(),
          
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