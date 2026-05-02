import 'dart:math'; // 👈 IMPORTANTE: Agregar esta línea
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleLoginButton extends StatefulWidget {
  final VoidCallback onSuccess;
  final Function(String)? onError;

  const GoogleLoginButton({
    super.key,
    required this.onSuccess,
    this.onError,
  });

  @override
  State<GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<GoogleLoginButton> {
  bool _isLoading = false;
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: "523415817476-ra15u5sc3bco0au2s0gc1sk22m2hs4p5.apps.googleusercontent.com",
  );

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      print('🔐 Iniciando Google Sign-In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Usuario canceló Google Sign-In');
        setState(() => _isLoading = false);
        return;
      }

      print('✅ Usuario autenticado: ${googleUser.displayName}');
      print('📧 Email: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? serverAuthCode = googleAuth.serverAuthCode;
      
      if (serverAuthCode == null) {
        throw Exception('No se pudo obtener serverAuthCode. Verifica que el Web Client ID esté configurado correctamente.');
      }
      
      // 👈 AHORA SÍ FUNCIONA
      print('🔑 ServerAuthCode obtenido (primeros 30): ${serverAuthCode.substring(0, min(30, serverAuthCode.length))}...');
      
      final userData = await ApiService.loginWithGoogle(serverAuthCode);

      print('✅ Sesión iniciada correctamente');
      print('📦 Usuario ID: ${userData['id']}');
      
      if (mounted) {
        widget.onSuccess();
      }
      
    } catch (error) {
      print('❌ Error en Google Sign-In: $error');
      
      String mensaje = 'Error al iniciar sesión con Google. ';
      if (error.toString().contains('10')) {
        mensaje = 'Error de configuración. Verifica que el SHA-1 esté registrado correctamente.';
      } else {
        mensaje += error.toString();
      }
      
      if (mounted) {
        _mostrarError(mensaje);
        widget.onError?.call(mensaje);
      }
      
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, maxLines: 3),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
              ),
        label: Text(
          _isLoading ? 'Conectando...' : 'Continuar con Google',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}