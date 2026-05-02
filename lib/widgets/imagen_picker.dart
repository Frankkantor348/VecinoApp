import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagenPicker extends StatefulWidget {
  final Function(File? imagen) onImagenSeleccionada;
  final String? imagenActual;

  const ImagenPicker({
    super.key,
    required this.onImagenSeleccionada,
    this.imagenActual,
  });

  @override
  State<ImagenPicker> createState() => _ImagenPickerState();
}

class _ImagenPickerState extends State<ImagenPicker> {
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();

  // ========== MÉTODO PARA OBTENER URL COMPLETA ==========
  String _getImagenUrl(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) return '';
    
    // Si ya tiene http, devolver igual
    if (imagenUrl.startsWith('http')) return imagenUrl;
    
    // Construir URL completa para el emulador
    return 'http://10.0.2.2:5067$imagenUrl';
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      // IMAGEN COMPRIMIDA
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,        // Ancho máximo en píxeles
        maxHeight: 1024,       // Alto máximo en píxeles
        imageQuality: 80,      // Calidad (0-100, 80 es óptimo)
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final sizeInKB = await file.length() / 1024;
        print('📸 Imagen seleccionada: ${sizeInKB.toStringAsFixed(1)} KB');
        
        setState(() {
          _imagenSeleccionada = file;
        });
        widget.onImagenSeleccionada(_imagenSeleccionada);
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _mostrarOpciones,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: _imagenSeleccionada != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _imagenSeleccionada!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            : widget.imagenActual != null && widget.imagenActual!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _getImagenUrl(widget.imagenActual),  // 👈 USAR URL COMPLETA
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Error cargando imagen: $error');
                        print('URL: ${_getImagenUrl(widget.imagenActual)}');
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                      const SizedBox(height: 8),
                      Text(
                        'Subir foto',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
      ),
    );
  }
}