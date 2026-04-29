
import 'package:flutter_test/flutter_test.dart';
import 'package:trackit_app/main.dart';

void main() {
  testWidgets('Carga de pantalla de login inicial', (WidgetTester tester) async {
    // Construimos nuestra app pasando isLoggedIn como false para que muestre el Login
    await tester.pumpWidget(const TrackItApp(isLoggedIn: false));

    // Verificamos que aparezca el nombre de la app "TRACKIT"
    expect(find.text('TRACKIT'), findsOneWidget);

    // Verificamos que existan los campos de texto o el botón de inicio de sesión
    expect(find.text('INICIAR SESIÓN'), findsOneWidget);
    
    // Verificamos que no estemos intentando buscar el contador del ejemplo de Flutter
    expect(find.text('0'), findsNothing);
  });
}