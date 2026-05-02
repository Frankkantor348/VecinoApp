import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vecinoapp/models/negocio.dart';
import 'package:vecinoapp/services/api_service.dart';
import '../widgets/star_rating.dart';
import '../widgets/resena_card.dart';
import '../widgets/producto_card.dart';
import '../widgets/promocion_card.dart';
import '../models/resena.dart';
import '../models/producto.dart';
import '../models/promocion.dart';
import 'crear_resena_screen.dart';
import '../widgets/favorito_icon.dart';
import 'registrar_negocio_screen.dart';
import 'gestion_productos_screen.dart';
import 'gestion_promociones_screen.dart';

class DetalleNegocioScreen extends StatefulWidget {
  final Negocio negocio;

  const DetalleNegocioScreen({
    super.key,
    required this.negocio,
  });

  @override
  State<DetalleNegocioScreen> createState() => _DetalleNegocioScreenState();
}

class _DetalleNegocioScreenState extends State<DetalleNegocioScreen> {
  late Negocio _negocio;
  List<Resena> _resenas = [];
  bool _isLoadingResenas = true;
  String? _errorResenas;
  
  bool _esPropietario = false;
  bool _esAdmin = false;
  
  int _promocionesRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    _negocio = widget.negocio;
    _verificarPermisos();
    _cargarResenas();
  }

  Future<void> _verificarPermisos() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuarioId');
    final rol = await ApiService.getUserRole();
    
    setState(() {
      _esPropietario = usuarioId == _negocio.propietarioId;
      _esAdmin = rol == 'Admin';
    });
  }

  Future<void> _cargarResenas() async {
    setState(() {
      _isLoadingResenas = true;
      _errorResenas = null;
    });
    try {
      final resenas = await ApiService.getResenasPorNegocio(_negocio.id);
      setState(() {
        _resenas = resenas;
        _isLoadingResenas = false;
      });
    } catch (e) {
      setState(() {
        _errorResenas = e.toString();
        _isLoadingResenas = false;
      });
    }
  }

  Future<void> _refrescarTodo() async {
    await _cargarResenas();
    setState(() {
      _promocionesRefreshKey++;
    });
  }

  String _getImagenUrl(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) return '';
    if (imagenUrl.startsWith('http')) return imagenUrl;
    
    const String baseUrl = 'http://192.168.20.9:5067';
    return '$baseUrl$imagenUrl';
  }

  // MÉTODO WHATSAPP CON MENSAJE PLANTILLA
  Future<void> _abrirWhatsApp(String telefono) async {
    // Limpiar el número
    String numeroLimpio = telefono
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('+', '');
    
    print('📞 Teléfono original: $telefono');
    print('📞 Teléfono limpio: $numeroLimpio');
    
    // Si no tiene código de país, agregar +57 (Colombia)
    if (!numeroLimpio.startsWith('57') && numeroLimpio.length == 10) {
      numeroLimpio = '57$numeroLimpio';
    }
    
    // Crear mensaje plantilla personalizado
    String mensaje = _crearMensajePlantilla();
    String mensajeCodificado = Uri.encodeComponent(mensaje);
    
    // PRIMERO INTENTAR CON whatsapp:// (abre directamente la app) con mensaje
    final String urlWhatsApp = 'whatsapp://send?phone=$numeroLimpio&text=$mensajeCodificado';
    print('📱 URL WhatsApp: $urlWhatsApp');
    
    // SEGUNDA OPCIÓN: api.whatsapp.com con mensaje
    final String urlWeb = 'https://api.whatsapp.com/send?phone=$numeroLimpio&text=$mensajeCodificado';
    
    try {
      // Intentar abrir con whatsapp:// primero
      if (await canLaunch(urlWhatsApp)) {
        await launch(urlWhatsApp);
      } 
      // Si no, intentar con la web
      else if (await canLaunch(urlWeb)) {
        await launch(urlWeb);
      }
      else {
        _mostrarDialogoWhatsApp(telefono);
      }
    } catch (e) {
      print('❌ Error: $e');
      _mostrarDialogoWhatsApp(telefono);
    }
  }

  // Función para crear el mensaje plantilla
  String _crearMensajePlantilla() {
    String mensaje = 'Hola, 👋\n\n';
    mensaje += 'He visto tu negocio *${_negocio.nombre}* en **VeciNoApp** y quisiera más información.';
    
    if (_negocio.tipo.isNotEmpty) {
      mensaje += '\n\n📌 Tipo: ${_negocio.tipo}';
    }
    
    mensaje += '\n\n📍 Dirección: ${_negocio.direccion}';
    
    mensaje += '\n\n\nQuedo atento a tu respuesta. ¡Gracias!';
    
    return mensaje;
  }

  void _mostrarDialogoWhatsApp(String telefono) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp no disponible'),
        content: Text('¿Deseas llamar al $telefono?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final String url = 'tel:$telefono';
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
            child: const Text('Llamar'),
          ),
        ],
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final String url = 'tel:$telefono';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _abrirMapa(String direccion) async {
    final String url = 'https://maps.google.com/?q=${Uri.encodeComponent(direccion)}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _editarNegocio() async {
    if (!_esPropietario && !_esAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permiso para editar este negocio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrarNegocioScreen(
          negocioId: _negocio.id,
          negocioData: {
            'nombre': _negocio.nombre,
            'tipo': _negocio.tipo,
            'direccion': _negocio.direccion,
            'telefono': _negocio.telefono,
            'whatsapp': _negocio.telefono,
            'horario': _negocio.horario,
            'latitud': _negocio.latitud,
            'longitud': _negocio.longitud,
            'imagenUrl': _negocio.imagenUrl,
            'propietarioId': _negocio.propietarioId,
          },
        ),
      ),
    );
    
    if (result == true) {
      try {
        final negocioActualizado = await ApiService.getNegocio(_negocio.id);
        setState(() {
          _negocio = negocioActualizado;
        });
        _refrescarTodo();
      } catch (e) {
        print('Error al recargar negocio: $e');
      }
    }
  }

  void _gestionarProductos() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GestionProductosScreen(
          negocioId: _negocio.id,
          negocioNombre: _negocio.nombre,
        ),
      ),
    );
    if (result == true) {
      _refrescarTodo();
    }
  }

  void _gestionarPromociones() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GestionPromocionesScreen(
          negocioId: _negocio.id,
          negocioNombre: _negocio.nombre,
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _promocionesRefreshKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_negocio.nombre),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (_esPropietario || _esAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'editar':
                    _editarNegocio();
                    break;
                  case 'productos':
                    _gestionarProductos();
                    break;
                  case 'promociones':
                    _gestionarPromociones();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Editar negocio'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'productos',
                  child: Row(
                    children: [
                      Icon(Icons.inventory, size: 20),
                      SizedBox(width: 8),
                      Text('Gestionar productos'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'promociones',
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, size: 20),
                      SizedBox(width: 8),
                      Text('Gestionar promociones'),
                    ],
                  ),
                ),
              ],
            ),
          FavoritoIcon(negocioId: _negocio.id),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.green.shade50,
                  child: _negocio.imagenUrl != null && _negocio.imagenUrl!.isNotEmpty
                      ? Image.network(
                          _getImagenUrl(_negocio.imagenUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print('❌ Error cargando imagen: $error');
                            print('URL intentada: ${_getImagenUrl(_negocio.imagenUrl)}');
                            return Container(
                              color: Colors.green.shade50,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('No se pudo cargar la imagen'),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.green.shade50,
                          child: const Center(
                            child: Icon(Icons.store, size: 80, color: Color(0xFF2E7D32)),
                          ),
                        ),
                ),
                if (_esPropietario || _esAdmin)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF2E7D32),
                        radius: 20,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                          onPressed: _editarNegocio,
                          padding: EdgeInsets.zero,
                          tooltip: 'Cambiar foto',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _negocio.tipo,
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    _negocio.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_negocio.calificacionPromedio != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StarRating(
                              rating: _negocio.calificacionPromedio!,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_negocio.calificacionPromedio!.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${_negocio.totalResenas ?? 0} reseñas)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  
                  _buildInfoRow(
                    Icons.location_on,
                    'Dirección',
                    _negocio.direccion,
                    isClickable: true,
                    onTap: () => _abrirMapa(_negocio.direccion),
                  ),
                  const SizedBox(height: 12),
                  
                  if (_negocio.telefono != null && _negocio.telefono!.isNotEmpty)
                    _buildInfoRow(
                      Icons.phone,
                      'Teléfono',
                      _negocio.telefono!,
                      isClickable: true,
                      onTap: () => _llamar(_negocio.telefono!),
                    ),
                  const SizedBox(height: 12),
                  
                  if (_negocio.telefono != null && _negocio.telefono!.isNotEmpty)
                    _buildWhatsAppRow(_negocio.telefono!),
                  const SizedBox(height: 12),
                  
                  if (_negocio.horario != null && _negocio.horario!.isNotEmpty)
                    _buildInfoRow(
                      Icons.access_time,
                      'Horario',
                      _negocio.horario!,
                    ),
                  const SizedBox(height: 24),
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Productos destacados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Producto>>(
                    future: ApiService.getProductosPorNegocio(_negocio.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final productos = snapshot.data ?? [];
                      if (productos.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No hay productos destacados'),
                          ),
                        );
                      }
                      return Column(
                        children: productos.map((p) => ProductoCard(producto: p)).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Promociones activas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Promocion>>(
                    key: ValueKey(_promocionesRefreshKey),
                    future: ApiService.getPromocionesActivasPorNegocio(_negocio.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final promociones = snapshot.data ?? [];
                      if (promociones.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('No hay promociones activas'),
                          ),
                        );
                      }
                      return Column(
                        children: promociones.map((p) => PromocionCard(promocion: p)).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Reseñas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  _isLoadingResenas
                      ? const Center(child: CircularProgressIndicator())
                      : _errorResenas != null
                          ? Center(child: Text('Error: $_errorResenas'))
                          : _resenas.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text('No hay reseñas aún. ¡Sé el primero en comentar!'),
                                  ),
                                )
                              : Column(
                                  children: _resenas.map((r) => ResenaCard(resena: r)).toList(),
                                ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CrearResenaScreen(
                              negocioId: _negocio.id,
                              negocioNombre: _negocio.nombre,
                            ),
                          ),
                        );
                        if (result == true) {
                          _refrescarTodo();
                        }
                      },
                      icon: const Icon(Icons.rate_review, color: Colors.white),
                      label: const Text(
                        'Escribir reseña',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          child: Icon(icon, size: 22, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              isClickable
                  ? GestureDetector(
                      onTap: onTap,
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsAppRow(String telefono) {
    if (telefono.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          child: const Icon(Icons.chat, size: 22, color: Color(0xFF25D366)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _abrirWhatsApp(telefono),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat, size: 18, color: Color(0xFF25D366)),
                      const SizedBox(width: 8),
                      Text(
                        telefono,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF25D366),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}