import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit(bool isSignUp) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (isSignUp) {
        await SupabaseService.instance.signUp(_email.text.trim(), _password.text);
      } else {
        await SupabaseService.instance.signIn(_email.text.trim(), _password.text);
      }
      if (mounted && SupabaseService.instance.isLoggedIn) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else if (mounted && isSignUp) {
        setState(() => _error = 'Revisa tu correo para confirmar la cuenta.');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueOffline() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [scheme.primary, scheme.primary.withOpacity(0.85)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('SmileVault',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Historia clínica dental digital',
                      style: TextStyle(color: Colors.white.withOpacity(0.85))),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.email_outlined)),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: Icon(Icons.lock_outline)),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12.5)),
                          ],
                          const SizedBox(height: 18),
                          if (_loading)
                            const CircularProgressIndicator()
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _submit(false),
                                child: const Text('Iniciar sesión'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _submit(true),
                                child: const Text('Crear cuenta'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: _continueOffline,
                              child: const Text(
                                  'Continuar sin cuenta (solo local)'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
