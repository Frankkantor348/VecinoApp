import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'package:vecinoapp/widgets/star_rating.dart';

class CrearResenaScreen extends StatefulWidget {
  final int negocioId;
  final String negocioNombre;

  const CrearResenaScreen({
    super.key,
    required this.negocioId,
    required this.negocioNombre,
  });

  @override
  State<CrearResenaScreen> createState() => _CrearResenaScreenState();
}

class _CrearResenaScreenState extends State<CrearResenaScreen> {
  int _calificacion = 5;
  final TextEditingController _comentarioController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarResena() async {
    // Validar comentario
    final comentarioTrimmed = _comentarioController.text.trim();
    
    if (comentarioTrimmed.isEmpty) {
      _mostrarMensaje(
        'Por favor escribe un comentario',
        Colors.orange,
      );
      return;
    }

    // Validar longitud del comentario
    if (comentarioTrimmed.length > 1000) {
      _mostrarMensaje(
        'El comentario no puede exceder los 1000 caracteres',
        Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📤 Enviando reseña:');
      print('   NegocioId: ${widget.negocioId}');
      print('   Calificacion: $_calificacion');
      print('   Comentario: $comentarioTrimmed');

      await ApiService.createResena(
        widget.negocioId,
        _calificacion,
        comentarioTrimmed,
      );

      print('✅ Reseña creada exitosamente');
      
      if (mounted) {
        _mostrarMensaje(
          '✅ Reseña publicada correctamente',
          Colors.green,
        );
        
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('❌ Error al crear reseña: $e');
      
      String mensajeError = 'Error al publicar la reseña';
      Color colorError = Colors.red;
      
      final errorMessage = e.toString();
      final errorLower = errorMessage.toLowerCase();
      
      // 👈 DETECCIÓN ESPECÍFICA PARA CONFLICT (409)
      if (errorLower.contains('409') || 
          errorLower.contains('conflict') ||
          errorLower.contains('ya has reseñado') || 
          errorLower.contains('ya has calificado') ||
          errorLower.contains('duplicate') ||
          errorLower.contains('ya existe') ||
          errorLower.contains('solo puedes reseñar')) {
        mensajeError = '⚠️ Ya has reseñado este negocio anteriormente.\nSolo puedes reseñar un negocio una vez.';
        colorError = Colors.orange;
      } 
      // Manejo de errores de validación 400
      else if (errorLower.contains('400') || errorLower.contains('bad request')) {
        if (errorLower.contains('calificación') || errorLower.contains('calificacion')) {
          mensajeError = '⭐ La calificación debe estar entre 1 y 5 estrellas';
        } else if (errorLower.contains('comentario')) {
          mensajeError = '💬 El comentario no es válido';
        } else if (errorLower.contains('usuario')) {
          mensajeError = '👤 Usuario no encontrado. Inicia sesión nuevamente.';
        } else if (errorLower.contains('negocio')) {
          mensajeError = '🏪 Negocio no encontrado.';
        } else {
          mensajeError = '📝 Datos inválidos. Verifica tu reseña.';
        }
        colorError = Colors.orange;
      }
      // Error de autenticación
      else if (errorLower.contains('401') || 
               errorLower.contains('unauthorized') ||
               errorLower.contains('sesión ha expirado') ||
               errorLower.contains('no autenticado')) {
        mensajeError = '🔐 Tu sesión ha expirado.\nPor favor inicia sesión nuevamente.';
        colorError = Colors.orange;
      }
      // Error del servidor
      else if (errorLower.contains('500') || errorLower.contains('internal server error')) {
        mensajeError = '🔄 Error en el servidor.\nPor favor intenta más tarde.';
        colorError = Colors.red;
      }
      // Error de conexión
      else if (errorLower.contains('timeout') || 
               errorLower.contains('connection') ||
               errorLower.contains('socket')) {
        mensajeError = '📡 Error de conexión.\nVerifica tu internet e intenta nuevamente.';
        colorError = Colors.red;
      }
      // Extraer mensaje del error si es posible
      else if (errorMessage.contains('Exception:')) {
        final parts = errorMessage.split('Exception:');
        if (parts.length > 1) {
          mensajeError = parts[1].trim();
          if (mensajeError.length > 150) {
            mensajeError = mensajeError.substring(0, 150) + '...';
          }
        }
      }
      
      _mostrarMensaje(mensajeError, colorError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escribir reseña'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (_comentarioController.text.isNotEmpty && !_isLoading) {
              _mostrarDialogoSalida();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del negocio
                    Text(
                      widget.negocioNombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección de calificación
                    const Text(
                      'Tu calificación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StarRating(
                          rating: _calificacion.toDouble(),
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$_calificacion/5',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _calificacion.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      activeColor: Colors.amber,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: _isLoading ? null : (value) {
                        setState(() {
                          _calificacion = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Sección de comentario
                    const Text(
                      'Tu comentario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _comentarioController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: '¿Qué opinas de este negocio?',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E7D32),
                            width: 2,
                          ),
                        ),
                        counterText: '',
                      ),
                      maxLines: 5,
                      maxLength: 1000,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        if (isFocused || currentLength > 900) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$currentLength/$maxLength',
                              style: TextStyle(
                                fontSize: 12,
                                color: currentLength > 900 
                                    ? (currentLength >= 1000 ? Colors.red : Colors.orange) 
                                    : Colors.grey,
                                fontWeight: currentLength >= 1000 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón de publicar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _enviarResena,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Publicar reseña',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoSalida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar reseña'),
        content: const Text('¿Estás seguro de que quieres salir?\nLos cambios no guardados se perderán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Seguir escribiendo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }
}