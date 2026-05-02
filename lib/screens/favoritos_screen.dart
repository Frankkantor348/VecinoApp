import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'package:vecinoapp/models/negocio.dart';
import 'detalle_negocio_screen.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Negocio> _favoritos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favoritos = await ApiService.getFavoritos();
      setState(() {
        _favoritos = favoritos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // MÉTODO PARA OBTENER URL COMPLETA DE LA IMAGEN
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
        title: const Text('Mis favoritos'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
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
                        onPressed: _cargarFavoritos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _favoritos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes favoritos aún',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el corazón en los negocios que te gusten',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarFavoritos,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favoritos.length,
                        itemBuilder: (context, index) {
                          final negocio = _favoritos[index];
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
                                  // IMAGEN DEL NEGOCIO (REAL)
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
                                                  child: const Icon(
                                                    Icons.store,
                                                    size: 40,
                                                    color: Colors.green,
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            color: isDarkMode 
                                                ? Colors.green.shade900 
                                                : Colors.green.shade50,
                                            child: const Icon(
                                              Icons.store,
                                              size: 40,
                                              color: Colors.green,
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
                                              negocio.tipo,
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
                                          if (negocio.calificacionPromedio != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.star, size: 14, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${negocio.calificacionPromedio!.toStringAsFixed(1)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(Icons.reviews, size: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${negocio.totalResenas} reseñas',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
    );
  }
}