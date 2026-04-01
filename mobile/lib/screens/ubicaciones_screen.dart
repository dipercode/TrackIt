
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UbicacionesScreen extends StatelessWidget {
  final int estacionId;
  final String estacionNombre;

  const UbicacionesScreen({super.key, required this.estacionId, required this.estacionNombre});

  Future<List<dynamic>> fetchUbicaciones() async {
    // Usamos la IP del emulador y el filtro que creamos en el backend
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/api/ubicaciones/?estacion=$estacionId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar ubicaciones');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ubicaciones: $estacionNombre"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUbicaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error cargando ubicaciones"));
          }
          
          final ubicaciones = snapshot.data!;
          
          if (ubicaciones.isEmpty) {
            return const Center(child: Text("No hay ubicaciones en esta sede"));
          }

          return ListView.builder(
            itemCount: ubicaciones.length,
            itemBuilder: (context, index) {
              final ubi = ubicaciones[index];
              return ListTile(
                leading: const Icon(Icons.place_outlined),
                title: Text(ubi["nombre"]),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Aquí irá la lógica para ver los activos de esta línea
                  print("Seleccionada: ${ubi['nombre']}");
                },
              );
            },
          );
        },
      ),
    );
  }
}