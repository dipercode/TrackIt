import 'package:flutter/material.dart';
import 'estaciones_screen.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    final username = _userController.text.trim();
    final password = _passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    bool success = await AuthService.login(username, password);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EstacionesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario o contraseña incorrectos"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // NUEVO: Función para mostrar el diálogo de recuperación
  void _showRecoverPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("RECUPERAR CONTRASEÑA"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Introduce tu email de Gmail y te enviaremos un enlace para restablecer tu clave."),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "CORREO ELECTRÓNICO",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              // 1. Guardamos la referencia al ScaffoldMessenger ANTES del await
              final messenger = ScaffoldMessenger.of(context);
              // 2. Guardamos la referencia al Navigator
              final navigator = Navigator.of(context);

              navigator.pop(); // Cerramos el diálogo

              try {
                final response = await http.post(
                  Uri.parse("http://10.0.2.2:8000/api/password_reset/"),
                  body: {'email': email},
                );

                // 3. Usamos la propiedad 'mounted' del State para validar
                if (!mounted) return;

                bool isOk = response.statusCode >= 200 && response.statusCode < 400;
                
                // 4. Usamos la referencia 'messenger' guardada previamente
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isOk 
                      ? "Si el correo está registrado, recibirás un enlace en breve." 
                      : "Error al solicitar la recuperación."),
                    backgroundColor: isOk ? Colors.green : Colors.orange,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text("Error de conexión con el servidor")),
                );
              }
            },
            child: const Text("ENVIAR"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              "TRACKIT",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Gestión de Activos Fijos",
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 50),
            
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "USUARIO",
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "CONTRASEÑA",
                prefixIcon: Icon(Icons.lock_outline),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
            ),
            
            // NUEVO: Botón de "¿Has olvidado tu contraseña?"
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showRecoverPasswordDialog,
                child: Text(
                  "¿Has olvidado tu contraseña?",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}