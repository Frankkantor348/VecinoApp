import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'package:vecinoapp/models/negocio.dart';
import 'detalle_negocio_screen.dart';
import '../widgets/categoria_filtro.dart';

class NegociosCercanosScreen extends StatefulWidget {
  final double latitud;
  final double longitud;

  const NegociosCercanosScreen({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<NegociosCercanosScreen> createState() => _NegociosCercanosScreenState();
}

class _NegociosCercanosScreenState extends State<NegociosCercanosScreen> {
  List<Negocio> _negocios = [];
  List<String> _categorias = [];  // 👈 Inicial vacío, no con 'Todos'
  bool _isLoading = true;
  bool _isLoadingCategorias = true;
  String? _categoriaSeleccionada;

  // Mapeo de nombres para mostrar
  final Map<String, String> _mapeoCategorias = {
    'cai tintal': 'CAIs',
    'barberia': 'Barberías',
    'tienda': 'Tiendas',
    'abarrotes': 'Abarrotes',
    'entrenemiento': 'Entrenamiento',
    'venta de libros': 'Librerías',
  };

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarNegocios();
  }
// Cargar categorías desde la API y mapear nombres para mostrar
 Future<void> _cargarCategorias() async {
  setState(() => _isLoadingCategorias = true);
  try {
    final categorias = await ApiService.getCategorias();
    
    print('📋 Categorías desde backend: $categorias');
    
    // 👈 FILTRO EXPLÍCITO: eliminar "Todos" si viene del backend
    final categoriasSinTodos = categorias.where((c) => c != 'Todos').toList();
    
    // Aplicar mapeo de nombres
    var categoriasMapeadas = categoriasSinTodos
        .map((c) => _mapeoCategorias.containsKey(c) ? _mapeoCategorias[c]! : c)
        .toSet()
        .toList()
      ..sort();
    
    // Agregar "Todos" al inicio (solo una vez)
    final listaFinal = ['Todos', ...categoriasMapeadas];
    
    print('📋 Lista final: $listaFinal');
    
    setState(() {
      _categorias = listaFinal;
      _isLoadingCategorias = false;
    });
  } catch (e) {
    print('❌ Error cargando categorías: $e');
    setState(() {
      _categorias = ['Todos', 'Tiendas', 'Restaurantes', 'Gimnasios', 'CAIs', 'Barberías'];
      _isLoadingCategorias = false;
    });
  }
}
  Future<void> _cargarNegocios() async {
    setState(() => _isLoading = true);
    try {
      // Obtener el tipo original para el filtro (desmapear)
      String? tipoOriginal = _categoriaSeleccionada;
      if (_categoriaSeleccionada != null && _categoriaSeleccionada != 'Todos') {
        // Buscar el tipo original en el mapeo inverso
        final inverso = _mapeoCategorias.entries
            .firstWhere(
              (entry) => entry.value == _categoriaSeleccionada,
              orElse: () => const MapEntry('', ''),
            )
            .key;
        
        tipoOriginal = inverso.isNotEmpty ? inverso : _categoriaSeleccionada;
      }
      
      final negocios = await ApiService.getNegociosCercanosConFiltro(
        widget.latitud,
        widget.longitud,
        radioMetros: 3000,
        tipo: _categoriaSeleccionada == 'Todos' ? null : tipoOriginal,
      );
      setState(() {
        _negocios = negocios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _cambiarFiltro(String? categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
    });
    _cargarNegocios();
  }

  double _calcularDistancia(double lat, double lng) {
    return Geolocator.distanceBetween(
      widget.latitud,
      widget.longitud,
      lat,
      lng,
    );
  }

  String _getImagenUrl(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) return '';
    if (imagenUrl.startsWith('http')) return imagenUrl;
    return 'http://10.0.2.2:5067$imagenUrl';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Negocios cercanos'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros de categoría
          if (_isLoadingCategorias)
            Container(
              padding: const EdgeInsets.all(12),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: const Center(
                child: SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: CategoriaFiltro(
                categorias: _categorias,
                categoriaSeleccionada: _categoriaSeleccionada,
                onCategoriaSeleccionada: _cambiarFiltro,
              ),
            ),
          // Lista de negocios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _negocios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _categoriaSeleccionada == null || _categoriaSeleccionada == 'Todos'
                                  ? 'No hay negocios cercanos'
                                  : 'No hay $_categoriaSeleccionada cercanas',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarNegocios,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _negocios.length,
                          itemBuilder: (context, index) {
                            final negocio = _negocios[index];
                            final distancia = _calcularDistancia(
                              negocio.latitud ?? 0,
                              negocio.longitud ?? 0,
                            );

                            final distanciaTexto = distancia < 1000
                                ? '${distancia.toStringAsFixed(0)} m'
                                : '${(distancia / 1000).toStringAsFixed(1)} km';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetalleNegocioScreen(negocio: negocio),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: negocio.imagenUrl != null && negocio.imagenUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                bottomLeft: Radius.circular(16),
                                              ),
                                              child: Image.network(
                                                _getImagenUrl(negocio.imagenUrl),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    color: isDarkMode 
                                                        ? Colors.green.shade900 
                                                        : Colors.green.shade50,
                                                    child: Icon(
                                                      Icons.store,
                                                      size: 40,
                                                      color: isDarkMode ? Colors.green.shade300 : Colors.green,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : Container(
                                              color: isDarkMode 
                                                  ? Colors.green.shade900 
                                                  : Colors.green.shade50,
                                              child: Icon(
                                                Icons.store,
                                                size: 40,
                                                color: isDarkMode ? Colors.green.shade300 : Colors.green,
                                              ),
                                            ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              negocio.nombre,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isDarkMode 
                                                    ? Colors.green.shade900 
                                                    : Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                // Mostrar nombre legible del tipo
                                                _mapeoCategorias.containsKey(negocio.tipo)
                                                    ? _mapeoCategorias[negocio.tipo]!
                                                    : negocio.tipo,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDarkMode 
                                                      ? Colors.green.shade300 
                                                      : Colors.green.shade700,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    size: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    negocio.direccion,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: isDarkMode ? Colors.grey[400] : Colors.grey),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.straighten,
                                                    size: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  distanciaTexto,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(Icons.chevron_right, 
                                        color: isDarkMode ? Colors.grey[400] : Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}