import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImagenConEdicion extends StatefulWidget {
  final String? imagenUrl;
  final Function(File nuevaImagen) onImagenSeleccionada;
  final VoidCallback onImagenEliminada;
  final double tamano;
  final bool esPerfil;

  const ImagenConEdicion({
    super.key,
    this.imagenUrl,
    required this.onImagenSeleccionada,
    required this.onImagenEliminada,
    this.tamano = 120,
    this.esPerfil = true,
  });

  @override
  State<ImagenConEdicion> createState() => _ImagenConEdicionState();
}

class _ImagenConEdicionState extends State<ImagenConEdicion> {
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

  Future<File?> _guardarImagen(File imagenTemporal) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nuevoArchivo = File('${tempDir.path}/img_$timestamp.jpg');
      
      // Leer bytes y guardar
      final bytes = await imagenTemporal.readAsBytes();
      await nuevoArchivo.writeAsBytes(bytes);
      
      print('✅ Imagen guardada: ${nuevoArchivo.path}');
      print('📏 Tamaño: ${bytes.length} bytes');
      
      return nuevoArchivo;
    } catch (e) {
      print('❌ Error al guardar: $e');
      return null;
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (foto != null) {
        final imagenGuardada = await _guardarImagen(File(foto.path));
        if (imagenGuardada != null) {
          setState(() => _imagenSeleccionada = imagenGuardada);
          widget.onImagenSeleccionada(imagenGuardada);
        }
      }
    } catch (e) {
      print('❌ Error al tomar foto: $e');
    }
  }

  Future<void> _elegirDeGaleria() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (imagen != null) {
        final archivo = File(imagen.path);
        print('📸 Imagen seleccionada: ${archivo.path}');
        print('📏 Tamaño: ${await archivo.length()} bytes');
        
        setState(() => _imagenSeleccionada = archivo);
        widget.onImagenSeleccionada(archivo);
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _tomarFoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _elegirDeGaleria();
              },
            ),
            if (widget.imagenUrl != null || _imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagenSeleccionada = null);
                  widget.onImagenEliminada();
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
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.tamano / 2,
            backgroundColor: Colors.grey[300],
            backgroundImage: _imagenSeleccionada != null
                ? FileImage(_imagenSeleccionada!)
                : (widget.imagenUrl != null && widget.imagenUrl!.isNotEmpty
                    ? NetworkImage(_getImagenUrl(widget.imagenUrl)) as ImageProvider  // 👈 USAR URL COMPLETA
                    : null),
            child: (widget.imagenUrl == null && _imagenSeleccionada == null)
                ? Icon(widget.esPerfil ? Icons.person : Icons.store, 
                    size: widget.tamano / 2, 
                    color: Colors.grey[600])
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                onPressed: _mostrarOpciones,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                iconSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}