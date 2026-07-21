import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La app funciona sin esto (modo 100% local); solo es necesario si vas
  // a usar cuentas/sincronización con Supabase. Ver services/supabase_service.dart.
  try {
    await SupabaseService.init();
  } catch (_) {
    // Sin configurar Supabase todavía: no rompe la app, solo no habrá
    // inicio de sesión ni sincronización hasta que pongas tus credenciales.
  }
  runApp(const DentalHistoryApp());
}

class DentalHistoryApp extends StatelessWidget {
  const DentalHistoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dentity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Layout pensado para tablet: se aprovecha bien en apaisado.
      home: const LoginScreen(),
    );
  }
}
