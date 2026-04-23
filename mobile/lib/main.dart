import 'package:flutter/material.dart';
import 'screens/estaciones_screen.dart';

void main() {
  runApp(const TrackItApp());
}

class TrackItApp extends StatelessWidget {
  const TrackItApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definición de colores estilo Threads/Modern
    const Color darkBg = Color(0xFF0F172A); // Fondo profundo
    const Color cardBg = Color(0xFF1E293B); // Gris azulado para tarjetas
    const Color accentColor = Color(0xFF38BDF8); // Cian eléctrico (Threads style)

    return MaterialApp(
      title: 'TrackIt',
      debugShowCheckedModeBanner: false, // Quitamos la etiqueta de debug
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        
        // Configuración de Esquema de Colores
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          secondary: Color(0xFF818CF8), // Índigo para variaciones
          surface: cardBg,
          onSurface: Colors.white,
        ),

        // Estilo de la AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBg,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            color: Colors.white,
            letterSpacing: 1.2
          ),
          iconTheme: IconThemeData(color: accentColor),
        ),

        // Estilo Global de Tarjetas
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              // Aquí corregimos el withOpacity por withValues
              color: Colors.white.withValues(alpha: 0.05), 
            ),
          ),
        ),

        // Estilo de botones flotantes
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          elevation: 4,
        ),
      ),
      home: const EstacionesScreen(),
    );
  }
}