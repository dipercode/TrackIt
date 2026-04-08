import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'ubicaciones_screen.dart';
import 'qr_scanner_screen.dart'; // 👈 IMPORTANTE: Importar la pantalla del escáner

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
    estaciones = ApiService.getEstaciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrackIt - Estaciones"),
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        // 👈 AÑADIMOS EL BOTÓN DE ESCANEO AQUÍ
        actions: [
          IconButton(
            tooltip: "Escanear Activo",
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: estaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error cargando estaciones"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay estaciones disponibles"));
          }

          final listaEstaciones = snapshot.data!;

          return ListView.separated(
            itemCount: listaEstaciones.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final estacion = listaEstaciones[index];

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.business, color: Colors.white),
                ),
                title: Text(
                  estacion["nombre"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(estacion["direccion"] ?? "Sin dirección"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  debugPrint("Navegando a ubicaciones de: ${estacion['nombre']}");
                  
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
              );
            },
          );
        },
      ),
    );
  }
}