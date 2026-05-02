import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vecinoapp/services/api_service.dart';
import '../models/usuario.dart';
import '../widgets/imagen_perfil.dart';
import '../providers/theme_provider.dart';
import 'editar_perfil_screen.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Usuario? _usuario;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final usuario = await ApiService.getPerfil();
      setState(() {
        _usuario = usuario;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('usuarioId');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (_usuario == null) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditarPerfilScreen(usuario: _usuario!),
                ),
              );
              if (result == true) {
                _cargarPerfil();
              }
            },
            tooltip: 'Editar perfil',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _cargarPerfil,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _usuario == null
                  ? const Center(child: Text('No se pudieron cargar los datos'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header con foto de perfil
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF2E7D32),
                                  Colors.green.shade700,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                ImagenPerfil(
                                  fotoUrl: _usuario!.fotoPerfilUrl,
                                  tamano: 120,
                                  onFotoActualizada: _cargarPerfil,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _usuario!.nombre,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _usuario!.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Estadísticas
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildEstadisticaCard(
                                  Icons.reviews,
                                  'Reseñas',
                                  _usuario!.totalResenas,
                                  Colors.blue,
                                ),
                                const SizedBox(width: 16),
                                _buildEstadisticaCard(
                                  Icons.favorite,
                                  'Favoritos',
                                  _usuario!.totalFavoritos,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ),
                          
                          // Switch de modo oscuro
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.dark_mode, size: 24),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        'Modo oscuro',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Consumer<ThemeProvider>(
                                      builder: (context, themeProvider, child) {
                                        return Switch(
                                          value: themeProvider.isDarkMode,
                                          onChanged: (_) => themeProvider.toggleTheme(),
                                          activeColor: Colors.green,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          
                          // Información personal
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Información personal',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow(
                                      Icons.person,
                                      'Nombre',
                                      _usuario!.nombre,
                                    ),
                                    const Divider(),
                                    _buildInfoRow(
                                      Icons.email,
                                      'Correo electrónico',
                                      _usuario!.email,
                                    ),
                                    if (_usuario!.telefono != null && _usuario!.telefono!.isNotEmpty)
                                      Column(
                                        children: [
                                          const Divider(),
                                          _buildInfoRow(
                                            Icons.phone,
                                            'Teléfono',
                                            _usuario!.telefono!,
                                          ),
                                        ],
                                      ),
                                    const Divider(),
                                    _buildInfoRow(
                                      Icons.calendar_today,
                                      'Miembro desde',
                                      _formatearFecha(_usuario!.fechaRegistro),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Botón cerrar sesión
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _cerrarSesion,
                              icon: const Icon(Icons.logout, color: Colors.white),
                              label: const Text(
                                'Cerrar sesión',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildEstadisticaCard(IconData icon, String label, int valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              valor.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}