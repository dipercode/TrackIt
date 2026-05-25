import 'package:flutter/material.dart';
import 'package:trackit_app/screens/login_screen.dart';
import 'package:trackit_app/screens/estaciones_screen.dart';
import 'package:trackit_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verificamos si ya hay un token guardado
  String? token = await AuthService.getToken();
  
  runApp(TrackItApp(isLoggedIn: token != null));
}

class TrackItApp extends StatelessWidget {
  final bool isLoggedIn;
  const TrackItApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const charcoal = Color(0xFF233D4C);
    const pumpkin = Color(0xFFFD802E);
    const cloudySky = Color(0xFFCBDDE9);
    const oceanBlue = Color(0xFF2872A1);

    return MaterialApp(
      title: 'TrackIt',
      debugShowCheckedModeBanner: false,
      
      // TEMA CLARO
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: cloudySky,
        colorScheme: ColorScheme.light(
          primary: oceanBlue,
          surface: Colors.white.withValues(alpha: 0.7),
          onSurface: charcoal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cloudySky,
          foregroundColor: charcoal,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: charcoal),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withValues(alpha: 0.9),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: charcoal,
        colorScheme: const ColorScheme.dark(
          primary: pumpkin,
          surface: Color(0xFF2D4A5D),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: charcoal,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2D4A5D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10),
          ),
        ),
      ),

      themeMode: ThemeMode.system, 
      // Si hay token, vamos directo a Estaciones, si no, al Login
      home: isLoggedIn ? const EstacionesScreen() : const LoginScreen(),
    );
  }
}